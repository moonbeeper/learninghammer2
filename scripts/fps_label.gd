extends Label
class_name UI_FPS

func _enter_tree() -> void:
	text = "000 FPS"

func update_ui_fps(_delta: float) -> void:
	text = "%s FPS" % str(Engine.get_frames_per_second())
	
func _process(delta: float) -> void:
	update_ui_fps(delta)
