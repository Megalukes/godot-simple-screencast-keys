@tool
extends EditorPlugin

const OVERLAY = preload("screencast_overlay.gd")

var overlay: Control


func _enter_tree() -> void:
	overlay = OVERLAY.new()
	EditorInterface.get_base_control().add_child(overlay)
	add_tool_menu_item("Toggle Screencast Keys", toggle)


func _exit_tree() -> void:
	remove_tool_menu_item("Toggle Screencast Keys")
	if overlay:
		overlay.queue_free()


func toggle() -> void:
	overlay.visible = not overlay.visible
