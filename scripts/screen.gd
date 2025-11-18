@tool
extends Node3D
class_name InteractableScreen

signal mouse_moved(pos: Vector2)
signal called_action(action_name: String)

@onready var parent: prop_interactable_screen = get_parent()

@export var viewport: SubViewport
@export var screen_mesh: MeshInstance3D
@export var area: Area3D
@export var screen_area_mesh: MeshInstance3D

var screen_material = preload("res://materials/models/screen/screen_screen_shader.tres")
var highlight_material = preload("res://materials/object_highlight.tres")
# always assume the ui design size is 1152x548.
var ui_design_size: Vector2 = Vector2(1152, 548)
var is_portrait: bool = false # used to rotate the cursor.
var last_mouse_pos: Vector2 = Vector2.ZERO
var is_mouse_over: bool = false


func _ready() -> void:
	parent._InternalCallAction.connect(func(e): called_action.emit(e))
	
	var screen_mat = screen_material.duplicate()
	screen_mesh.set_surface_override_material(0, screen_mat)

func _process(_delta: float) -> void:
	var tex = viewport.get_texture()
	var mat = screen_mesh.get_surface_override_material(0) as ShaderMaterial
	mat.set_shader_parameter("screen_tex", tex)

func world_to_viewport_pos(world_hit_pos: Vector3) -> Vector2:
	var local_pos = screen_area_mesh.global_transform.affine_inverse() * world_hit_pos
	
	var uv = Vector2((-local_pos.y / screen_area_mesh.mesh.size.y) + 0.5, (-local_pos.x / screen_area_mesh.mesh.size.x) + 0.5)
	uv = Vector2(clamp(uv.x, 0.0, 1.0), clamp(uv.y, 0.0, 1.0))
	
	var pos2d = Vector2(uv.x * viewport.size.x, uv.y * viewport.size.y)
	return pos2d

func emit_cursor_position(world_hit_pos: Vector3):
	#screen_mesh.material_overlay = highlight_material.duplicate()
	var pos2d = world_to_viewport_pos(world_hit_pos)
	
	var motion_event = InputEventMouseMotion.new()
	motion_event.position = pos2d
	motion_event.global_position = pos2d
	motion_event.relative = pos2d - last_mouse_pos
	
	last_mouse_pos = pos2d
	viewport.push_input(motion_event)
	mouse_moved.emit(pos2d)

func on_screen_clicked(world_hit_pos: Vector3):
	var pos2d = world_to_viewport_pos(world_hit_pos)
	
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.position = pos2d
	press_event.global_position = pos2d
	press_event.button_mask = MOUSE_BUTTON_MASK_LEFT
	viewport.push_input(press_event)
	
	var release_event = InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.position = pos2d
	release_event.global_position = pos2d
	viewport.push_input(release_event)
	
## Trigger an action to be sent to the map IO
func trigger_action(id: int) -> void:
	var clamped_id = clampi(id, 1, 4)
	
	match clamped_id:
		1:
			parent.trigger_output("OnAction1");
		2:
			parent.trigger_output("OnAction2");
		3:
			parent.trigger_output("OnAction3");
		4:
			parent.trigger_output("OnAction4");

# can't do this, the signal has to be handled by the UI
#func _on_call_action(action_name) -> void: pass

func _on_hovered() -> void:
	pass
