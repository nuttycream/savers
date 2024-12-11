@tool
extends Control

var script_list: ItemList
var ignore_list: ItemList
var fs: EditorFileSystem
var savers: Node

func _ready() -> void:
	script_list = $VBoxContainer/ScriptList
	ignore_list = $VBoxContainer/IgnoreList
	
	var refresh_btn = $VBoxContainer/RefreshButton
	refresh_btn.pressed.connect(do_scan)
	
	var add_ignore_btn = $VBoxContainer/HBoxContainer/AddIgnoreButton
	add_ignore_btn.pressed.connect(add_to_ignore)
	
	var remove_ignore_btn = $VBoxContainer/HBoxContainer/RemoveIgnoreButton
	remove_ignore_btn.pressed.connect(remove_from_ignore)
	
	fs = EditorInterface.get_resource_filesystem()

	await get_tree().process_frame
	savers = get_node("/root/Savers")
	refresh_lists()

func refresh_lists() -> void:
	do_scan()
	update_ignore_list()

func do_scan() -> void:
	script_list.clear()
	var scripts = ["res://"]
	var ignore = ["addons"]
	
	while scripts:
		var dir = DirAccess.open(scripts.pop_front())
		if not dir: continue
		
		dir.list_dir_begin()
		var name = dir.get_next()
		
		while name:
			if name.begins_with(".") or name in ignore:
				name = dir.get_next()
				continue
				
			var path = dir.get_current_dir().path_join(name)
			
			if dir.current_is_dir():
				scripts.push_back(path)
			elif name.ends_with(".gd"):
				scan_script(path)
			
			name = dir.get_next()
		dir.list_dir_end()

func scan_script(path: String) -> void:
	var script = load(path)
	if script:
		for prop in script.get_script_property_list():
			if prop["usage"] & PROPERTY_USAGE_EDITOR:
				script_list.add_item("%s: %s (%s)" % [path, prop["name"], prop["type"]])
				script_list.set_item_metadata(script_list.get_item_count() - 1, {
					"path": path,
					"var": prop["name"]
				})

func update_ignore_list() -> void:
	ignore_list.clear()
	for node_path in savers.ignored_vars:
		for var_name in savers.ignored_vars[node_path]:
			ignore_list.add_item("%s: %s" % [node_path, var_name])
			ignore_list.set_item_metadata(ignore_list.get_item_count() - 1, {
				"path": node_path,
				"var": var_name
			})

func add_to_ignore() -> void:
	var selected = script_list.get_selected_items()
	for idx in selected:
		var metadata = script_list.get_item_metadata(idx)
		savers.add_ignored_var(metadata["path"], metadata["var"])
	update_ignore_list()

func remove_from_ignore() -> void:
	var selected = ignore_list.get_selected_items()
	for idx in selected:
		var metadata = ignore_list.get_item_metadata(idx)
		savers.remove_ignored_var(metadata["path"], metadata["var"])
	update_ignore_list()
