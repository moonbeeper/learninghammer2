extends PanelContainer

@export var label: RichTextLabel
@export var with_key_name_container: HBoxContainer
@export var key_name_label: Label
@export var key_label1: RichTextLabel
@export var key_label2: RichTextLabel

var key_name_prefab = preload("res://nodes/caption_key_name.tscn")
var caption_label_prefab = preload("res://nodes/caption_label.tscn")
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
	SoundManager.precache_sound("beepclear.mp3")
	
func start_timer() -> void:
	if show_time == -1.0: return # if its -1 we don't want to have a timeout
	timer.wait_time = show_time
	timer.start()
	
func _on_show_instructor_hint(hint: String, time: float) -> void:
	show_time = time
	if is_active: await tween_to_hide()
	
	is_active = true
	
	clean_key_name()
	if hint.contains("%"):
		set_split_key_string(hint)
	else:
		label.visible = true
		with_key_name_container.visible = false
		label.text = hint
	#reset_pivot()
	
	# REPLACE ME GOD DAMMIT ITS A VALVE SOUND!!!!
	SoundManager.play_sound(Player.INSTANCE.global_position, "beepclear.mp3")
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

func get_key_name(action: String) -> String:
	print(action)
	var maps = InputMap.action_get_events(action)
	print(maps)
	if maps.is_empty():
		return "???"
		
	var bind = maps[0]
	if bind is InputEventKey:
		return OS.get_keycode_string(bind.physical_keycode)
	else:
		return "???"
		
#func set_split_key_string(string: String) -> void:
	#var start_idx = string.find("%")
	#var end_idx = string.find("%", start_idx+1)
	#
	#var action_name = string.substr(start_idx + 1, end_idx-start_idx-1) 
	#var key_name = get_key_name(action_name)
	#
	#var before_keyname: String = string.substr(0, start_idx - 1).strip_edges()
	#var after_keyname: String = string.substr(end_idx + 1).strip_edges()
	#
	#label.visible = false
	#with_key_name_container.visible = true
	#
	#key_label1.text = before_keyname
	#key_label2.text = after_keyname
	#key_name_label.text = key_name

# now with the deluxe edition of this method you get to use multiple %action%s!
func set_split_key_string(string: String) -> void:
	#clean_key_name()
	label.visible = false
	with_key_name_container.visible = true
	
	var pos = 0
	
	while pos < string.length():
		var start_idx = string.find("%", pos)
		
		if start_idx == -1:
			if pos < string.length():
				var text = string.substr(pos).strip_edges()
				if text.length() > 0:
					var text_label = caption_label_prefab.instantiate()
					text_label.text = text
					with_key_name_container.add_child(text_label)
			break
		
		if start_idx > pos:
			var text = string.substr(pos, start_idx - pos).strip_edges()
			if text.length() > 0:
				var text_label = caption_label_prefab.instantiate()
				text_label.text = text
				with_key_name_container.add_child(text_label)				
		
		var end_idx = string.find("%", start_idx+1)
		var action_name = string.substr(start_idx + 1, end_idx-start_idx-1) 
		var key_name = get_key_name(action_name)
		
		var key_label = key_name_prefab.instantiate()
		key_label.text = key_name
		with_key_name_container.add_child(key_label)
		
		pos = end_idx+1


func clean_key_name() -> void:
	for child in with_key_name_container.get_children():
		child.queue_free()
