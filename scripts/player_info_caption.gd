extends PanelContainer

@export var label: RichTextLabel

var is_active: bool = false
var timer: Timer
var show_time: float = 1.0

func _ready() -> void:
	await get_tree().process_frame
	Player.INSTANCE.ShowInstructorHint.connect(_on_show_instructor_hint)
	Player.INSTANCE.HideInstructorHint.connect(_on_hide_instructor_hint)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	modulate = Color(1,1,1,0)
	
func start_timer() -> void:
	if show_time == -1.0: return # if its -1 we don't want to have a timeout
	timer.wait_time = show_time
	timer.start()
	
func _on_show_instructor_hint(hint: String, time: float) -> void:
	show_time = time
	if is_active: await tween_to_hide()
	
	is_active = true
	label.text = hint
	#reset_pivot()
	
	start_timer()
	await tween_to_show()
	
func _on_hide_instructor_hint() -> void:
	if !is_active: return
	timer.stop()
	tween_to_hide()
	
	label.text = "unknown"
	#reset_pivot()
	
func _on_timer_timeout() -> void:
	tween_to_hide()

func tween_to_hide() -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.1)
	await tween.finished
	
func tween_to_show() -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	tween.chain().tween_property(self, "modulate", Color(1.5,1.5,1.5,1), 0.1)
	tween.chain().tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	await tween.finished
#
#func reset_pivot() -> void: 
	#var current_size = size
	#pivot_offset = Vector2(current_size.x/2, current_size.y/2)
	
