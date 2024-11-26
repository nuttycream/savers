@tool
extends EditorPlugin

var dock
var singleton_name = "Savers"

func _enter_tree() -> void:
	add_autoload_singleton(singleton_name, "res://addons/savers/save_manager.gd")
	
	dock = preload("res://addons/savers/saversdock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree() -> void:
	remove_autoload_singleton(singleton_name)
	remove_control_from_docks(dock)
	dock.queue_free()
