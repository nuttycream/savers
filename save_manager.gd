@tool
extends Node

# ideally we want this to be set by devs
const SAVE_PATH := "user://save.json"
var save_nodes: Array[Node] = []

func _ready() -> void:
	await get_tree().process_frame
	save_nodes = get_vars(get_tree().root)
	load_game()

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

func save() -> void:
	var save_data := {}
	
	for node in save_nodes:
		if not is_instance_valid(node): continue
		
		var props := {}
		for prop in node.get_script().get_script_property_list():
			props[prop["name"]] = node.get(prop["name"])
		
		save_data[node.get_path()] = {
			"scene_path": node.scene_file_path,
			"node_path": str(node.get_path()),
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
			node.set(prop_name, data["properties"][prop_name])
			
	print("loaded save")
