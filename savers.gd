@tool
extends EditorPlugin

var main_view
var singleton_name = "Savers"

func _enter_tree() -> void:
	add_autoload_singleton(singleton_name, "res://addons/savers/save_manager.gd")
	
	main_view = preload("res://addons/savers/saversdock.tscn").instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_view)
	_make_visible(false)

func _has_main_screen() -> bool:
	return true

func _make_visible(vis: bool) -> void:
		main_view.visible = vis

func _get_plugin_name() -> String:
	return "Savers"

func _exit_tree() -> void:
	remove_autoload_singleton(singleton_name)
	main_view.queue_free()
