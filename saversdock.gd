@tool
extends Panel

var script_list: ItemList

func _ready():
	script_list = $VBoxContainer/ScriptList
	var refresh_btn = $VBoxContainer/RefreshButton
	refresh_btn.pressed.connect(clear_list)

func clear_list() -> void:
	script_list.clear()
