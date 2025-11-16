extends Label
class_name UIScreenClock
@export var blink_interval: float = 0.5

var blink_timer: float = 0.0
var colon_visible: bool = true

func _process(delta: float) -> void:
	blink_timer += delta
	if blink_timer >= blink_interval:
		blink_timer = 0.0
		colon_visible = !colon_visible
	
	var hours = Global.hours
	var minutes = Global.minutes
	var colon = ":" if colon_visible else " "
	
	text = "%d%s%02d PM" % [hours, colon, minutes] # always pm lol, 34:3pm
