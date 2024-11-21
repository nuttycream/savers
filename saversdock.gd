@tool
extends Panel

var script_list: ItemList
var fs: EditorFileSystem

func _ready():
	script_list = $VBoxContainer/ScriptList
	var refresh_btn = $VBoxContainer/RefreshButton
	refresh_btn.pressed.connect(do_scan)
	
	fs = EditorInterface.get_resource_filesystem()

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
				var script = load(path)
				if script:
					for prop in script.get_script_property_list():
						if prop["usage"] & PROPERTY_USAGE_EDITOR:
							script_list.add_item("%s: %s" % [path, prop["name"]])
			
			name = dir.get_next()
		dir.list_dir_end()
