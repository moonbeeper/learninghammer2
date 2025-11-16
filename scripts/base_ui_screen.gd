extends Control
class_name BaseUIScreen

@onready var parent: InteractableScreen = get_parent().get_parent()
@export var hide_cursor: bool = false

var cursor_sprite = preload("res://materials/cursor.png")
var cursor: TextureRect = null

func _ready() -> void:
	# great job me.
	parent._OnPushAction1.connect(_onPushAction1)
	parent._OnPushAction2.connect(_onPushAction2)
	parent._OnPushAction3.connect(_onPushAction3)
	parent._OnPushAction4.connect(_onPushAction4)

	parent.mouse_moved.connect(_on_mouse_moved)
	
	# If we add the cursor directly to the node, we might not be able to see it thanks to the zindex of stuff.
	var canvas = CanvasLayer.new()
	
	cursor = TextureRect.new()
	cursor.texture = cursor_sprite.duplicate()
	cursor.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	cursor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cursor.size = Vector2(64, 64)
	cursor.z_index = 100 # just to be sure, even if we are inside a separate canvas
	cursor.rotation_degrees = -90 if parent.is_portrait else 0
	cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(canvas)
	canvas.add_child(cursor)
	
	_ui_ready()

func _on_mouse_moved(pos: Vector2) -> void:
	if !cursor or hide_cursor: return
	cursor.position = pos - cursor.size * 0.001

## Called after the creation of the base nodes
func _ui_ready() -> void: pass

func _onPushAction1() -> void: pass
func _onPushAction2() -> void: pass
func _onPushAction3() -> void: pass
func _onPushAction4() -> void: pass
