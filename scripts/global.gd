extends Node

var hours: int = 4
var minutes: int = 30
var time_scale: float = 0.1 
var tick: float = 0.0

func _process(delta: float) -> void:
	tick += delta * time_scale
	
	if tick >= 1.0:
		tick -= 1.0
		add_minute()

func add_minute():
	minutes += 1
	
	if minutes >= 60:
		minutes = 0
		hours += 1
		
		if hours > 12:
			hours = 1
