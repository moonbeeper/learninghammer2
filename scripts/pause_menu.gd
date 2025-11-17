extends Control

@export var resume_button: Button
@export var select_map_button: Button
@export var reload_map: Button
@export var exit_to_desktop: Button


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume()
			return
		visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func resume() -> void:
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Player.INSTANCE.is_cursor_captured = true

func _on_resume_pressed() -> void:
	resume()

func _on_select_map_pressed() -> void:
	pass # Replace with function body.

func _on_reload_map_pressed() -> void:
	pass # Replace with function body.

func _on_exit_to_desktop_pressed() -> void:
	get_tree().quit()
