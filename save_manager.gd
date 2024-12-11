@tool
extends Node

# ideally we want this to be set by devs
const SAVE_PATH := "user://save.json"
const CONFIG_PATH := "res://addons/savers/config.json"

var save_nodes: Array[Node] = []
var ignored_vars: Dictionary = {}

func _ready() -> void:
	await get_tree().process_frame
	load_config()
	save_nodes = get_vars(get_tree().root)
	load_game()

func load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		ignored_vars = {}
		return
		
	var json := JSON.new()
	var err := json.parse(FileAccess.open(CONFIG_PATH, FileAccess.READ).get_as_text())
	
	if err != OK:
		print("failed to load config")
		ignored_vars = {}
		return
		
	ignored_vars = json.get_data()

func save_config() -> void:
	FileAccess.open(CONFIG_PATH, FileAccess.WRITE).store_string(
		JSON.stringify(ignored_vars, "  ")
	)
	print("config saved")

func get_vars(root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	
	if root.get_script():
		for prop in root.get_script().get_script_property_list():
			if prop["usage"] & PROPERTY_USAGE_EDITOR:
				nodes.append(root)
				break
	
	for child in root.get_children():
		nodes.append_array(get_vars(child))
	
	return nodes

func is_var_ignored(node: Node, var_name: String) -> bool:
	var script_path = node.get_script().resource_path
	return script_path in ignored_vars and var_name in ignored_vars[script_path]

func add_ignored_var(script_path: String, var_name: String) -> void:
	if not script_path in ignored_vars:
		ignored_vars[script_path] = []
	if not var_name in ignored_vars[script_path]:
		ignored_vars[script_path].append(var_name)
		save_config()

func remove_ignored_var(script_path: String, var_name: String) -> void:
	if script_path in ignored_vars and var_name in ignored_vars[script_path]:
		ignored_vars[script_path].erase(var_name)
		if ignored_vars[script_path].is_empty():
			ignored_vars.erase(script_path)
		save_config()

func save() -> void:
	var save_data := {}
	
	for node in save_nodes:
		if not is_instance_valid(node): continue
		
		var props := {}
		var node_path := str(node.get_path())
		for prop in node.get_script().get_script_property_list():
			if not is_var_ignored(node, prop["name"]):
				props[prop["name"]] = node.get(prop["name"])
		
		if not props.is_empty():
			save_data[node_path] = {
				"scene_path": node.scene_file_path,
				"node_path": node_path,
				"properties": props
			}
	
	FileAccess.open(SAVE_PATH, FileAccess.WRITE).store_string(
		JSON.stringify(save_data, "  ")
	)
	print("game saved")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("no save found")
		return
	
	var json := JSON.new()
	var err := json.parse(FileAccess.open(SAVE_PATH, FileAccess.READ).get_as_text())
	
	if err != OK:
		print("failed to load")
		return
		
	var save_data: Dictionary = json.get_data()
	save_nodes = get_vars(get_tree().root)
	
	for node in save_nodes:
		var path := str(node.get_path())
		var data: Dictionary = save_data.get(path, {})
		
		if data.is_empty() or node.scene_file_path != data.get("scene_path"): 
			continue
			
		for prop_name in data.get("properties", {}):
			if not is_var_ignored(node, prop_name):
				node.set(prop_name, data["properties"][prop_name])
			
	print("loaded save")
