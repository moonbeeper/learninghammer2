extends CharacterBody3D
class_name Player

static var INSTANCE: Player

signal ShowInstructorHint(hint: String, time: float)
signal HideInstructorHint()

@export var head: Node3D
@export var collision: CollisionShape3D
@export var camera: Camera3D
@export var ray_stair_below: RayCast3D
@export var ray_stair_front: RayCast3D
@export var hand_point: Node3D
@export var flash_spot_light: SpotLight3D
#@export var ui_fps_label: Label
@export var ui_crosshair: TextureRect

@export var mouse_sensitivity: float = 0.1
@export var acceleration: float = 10.0
@export var movement_speed: float = 5.0
@export var movement_crouch_speed: float = 3.0
@export var movement_speed_change: float = 4.0
@export var movement_noclip_speed_mult: float = 150.0
@export var jump_height: float = 1.0
@export_range(0.0, 1.0, 0.1) var crouch_height_percent: float = 0.5
@export var crouch_speed: float = 30.0
@export var max_step_height: float = 0.49
@export var interaction_distance: float = 3.0
@export var flashlight_position_smoothness: float = 15.0
@export var flashlight_rotation_smoothness: float = 15.0
@export var max_head_rotation: float = 70.0
@export var crosshair_tween_duration: float = 0.2

var pickup_processor: PlayerPickupProcessor = null

var collision_height: float = 0.0
var _last_frame_was_on_floor: int = -1
var _snapped_to_stairs_last_frame: bool = false
var is_cursor_captured: bool = false
var is_flashlight_enabled: bool = false
var current_movement_speed: float = 1.0
var is_noclip: bool = false
var current_screen_terminal = null
var current_screen_terminal_hitpos: Vector3 = Vector3.ZERO
var crosshair_tween: Tween
var crosshair_tween_inprogress: bool = false
func _ready() -> void:
	INSTANCE = self
	ValveIONode.define_alias("!player", self);

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	is_cursor_captured = true
	collision_height = collision.shape.height 
	pickup_processor = PlayerPickupProcessor.new(hand_point);
	current_movement_speed = movement_speed

func _input(event: InputEvent) -> void:
	input_mouse_event_move(event)
	input_capture_mouse(event)
	input_interact(event)
	input_throw(event)
	input_flashlight(event)
	input_noclip(event)
	input_mouse_noclip_speed(event)
	input_screen_click(event)
	
func input_mouse_event_move(event: InputEvent):	
	if !event is InputEventMouseMotion or !is_cursor_captured: return 
	var this = event as InputEventMouseMotion
	rotate_y(deg_to_rad(-this.relative.x * mouse_sensitivity))
	head.rotate_x(deg_to_rad(-this.relative.y * mouse_sensitivity))
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-max_head_rotation), deg_to_rad(max_head_rotation))
	
func input_capture_mouse(event: InputEvent):
	if !OS.is_debug_build(): return
	if event.is_action_pressed("ui_cancel") and is_cursor_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_cursor_captured = false
	if event is InputEventMouseButton and !is_cursor_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_cursor_captured = true

func input_throw(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		if pickup_processor.has_item():
			pickup_processor.throw_item()

func input_interact(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if pickup_processor.has_item():
			pickup_processor.drop_item()
			return

		var ray_start = camera.global_transform.origin
		var ray_end = camera.global_transform.origin - camera.global_transform.basis.z * interaction_distance
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1, [self])
		var result = get_world_3d().direct_space_state.intersect_ray(query)

		if result and result.collider:
			var body = result.collider.get_parent()
			if body.has_method("_interact_and_pickup"):
				body._interact(self)
			if body.has_method("_interact"):
				print("body has _interact method, exiting method")
				body._interact(self)
				return
			# gets mad if interact to a csg something with collision.
			# even though the method is already checking that its a rigidbody3d.
			if result is RigidBody3D:
				pickup_processor.pickup_item(result.collider)

func input_flashlight(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		if is_flashlight_enabled:
			is_flashlight_enabled = false
			flash_spot_light.visible = is_flashlight_enabled
		else:
			is_flashlight_enabled = true
			flash_spot_light.visible = is_flashlight_enabled
			
func input_noclip(event: InputEvent) -> void:
	if event.is_action_pressed("noclip"):
		if is_noclip:
			is_noclip = false
			collision.disabled = false
		else:
			is_noclip = true
			collision.disabled = true

func input_mouse_noclip_speed(event: InputEvent):	
	if !event is InputEventMouseButton or !is_noclip: return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		movement_noclip_speed_mult = min(300.0, movement_noclip_speed_mult * 1.1)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		movement_noclip_speed_mult = max(0.1, movement_noclip_speed_mult * 0.9)
	
func input_screen_click(event: InputEvent) -> void:
	if !current_screen_terminal: return
	
	var should_click = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_cursor_captured:
			should_click = true
			print("should click")
	elif event.is_action_pressed("interact"):
		should_click = true
		print("should click (E)")
	
	if should_click:
		if current_screen_terminal.has_method("on_screen_clicked"):
			current_screen_terminal.on_screen_clicked(current_screen_terminal_hitpos)
		
func _process(delta: float) -> void:
	process_flashlight_movement(delta)
	process_interaction_screen_cursor(delta)
	
func _physics_process(delta: float) -> void:
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	process_movement(delta)
	process_jump(delta)
	process_crouch(delta)
	process_noclip_movement(delta)
	pickup_processor.physics_process(delta);
		
func process_movement(delta: float) -> void:
	if is_noclip: return
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0 , input_dir.y)).normalized()
	
	velocity.x = lerp(velocity.x, direction.x * current_movement_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, direction.z * current_movement_speed, acceleration * delta)
	if !try_snap_up_check(delta):
		move_and_slide()
		try_snap_down(delta)

func process_jump(_delta: float) -> void:
	if is_on_floor() or _snapped_to_stairs_last_frame:
		if Input.is_action_just_pressed("jump"):
			velocity.y = sqrt(2 * jump_height * get_gravity().length());

func process_crouch(delta: float) -> void:
	var is_crouching = Input.is_action_pressed("crouch")
	
	if is_crouching:
		current_movement_speed = lerp(current_movement_speed, movement_crouch_speed, movement_speed_change * delta)
	else:
		current_movement_speed = lerp(current_movement_speed, movement_speed, movement_speed_change * delta)
	
	var crouch_height = collision_height * crouch_height_percent
	var target_height = crouch_height if is_crouching else collision_height
	
	collision.shape.height = lerp(collision.shape.height, target_height, crouch_speed * delta)

func process_flashlight_movement(delta: float) -> void:
	var sbasis = flash_spot_light.global_basis.slerp(camera.global_basis, delta * flashlight_rotation_smoothness)
	var origin = flash_spot_light.global_transform.origin.slerp(camera.global_transform.origin, delta * flashlight_position_smoothness)
	
	flash_spot_light.global_transform = Transform3D(sbasis, origin)

func process_noclip_movement(delta: float) -> void:	
	if !is_noclip: return	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var speed: float = movement_speed * movement_noclip_speed_mult
	
	velocity += (head.global_basis.z * input_dir.y + head.global_basis.x * input_dir.x) * speed * delta
	velocity *= .5
	
	move_and_slide()

func process_interaction_screen_cursor(_delta: float) -> void:
	var ray_start = camera.global_transform.origin
	var ray_end = camera.global_transform.origin - camera.global_transform.basis.z * interaction_distance
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1, [self])
	query.collide_with_areas = true
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result and result.collider and result.collider.is_in_group("ScreenInteraction"):
		var screen_terminal = result.collider.get_parent()
		current_screen_terminal = screen_terminal
		current_screen_terminal_hitpos = result.position
		
		if screen_terminal.has_method("emit_cursor_position"):
			screen_terminal.emit_cursor_position(result.position)
		hide_crosshair()
	else:
		current_screen_terminal = null
		current_screen_terminal_hitpos = Vector3.ZERO
		show_crosshair()
				
#https://www.youtube.com/watch?v=Tb-R3l0SQdc
func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func try_snap_down(_delta: float) -> void:
	var did_snap: bool = false
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	
	var floor_below: bool = ray_stair_below.is_colliding() and !is_surface_too_steep(ray_stair_below.get_collision_normal())
	
	if !is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new()
		if test_move(global_transform, Vector3(0, -max_step_height, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func try_snap_up_check(delta: float) -> bool:
	if !is_on_floor() and !_snapped_to_stairs_last_frame: return false
	var expected_move_motion = velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = global_transform.translated(expected_move_motion + Vector3(0, max_step_height * 2, 0))
	
	var body_test_result = KinematicCollision3D.new()
	if test_move(step_pos_with_clearance, Vector3(0, -max_step_height * 2, 0), body_test_result) and (body_test_result.get_collider().is_class("StaticBody3D") or body_test_result.get_collider().is_class("RigidBody3D")):
		var step_height = ((step_pos_with_clearance.origin + body_test_result.get_travel()) - global_position).y
		if step_height > max_step_height or step_height <= 0.01 or (body_test_result.get_position() - global_position).y > max_step_height: return false
		
		ray_stair_front.global_position = body_test_result.get_position() + Vector3(0, max_step_height, 0) + expected_move_motion.normalized() * 0.1
		ray_stair_front.force_raycast_update()
		if ray_stair_front.is_colliding() and !is_surface_too_steep(ray_stair_front.get_collision_normal()):
			global_position = step_pos_with_clearance.origin + body_test_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false
	
func hide_crosshair() -> void:
	if crosshair_tween_inprogress: return
	
	var mat = ui_crosshair.material as ShaderMaterial
	if mat and mat.get_shader_parameter("alpha") == 0.0: return
	
	crosshair_tween_inprogress = true
	if crosshair_tween and crosshair_tween.is_running():
		crosshair_tween.kill()
	
	crosshair_tween = create_tween()
	crosshair_tween.tween_property(ui_crosshair.material, "shader_parameter/alpha", 0.0, crosshair_tween_duration)
	crosshair_tween.finished.connect(func(): crosshair_tween_inprogress = false)  # Use signal instead of await!

func show_crosshair() -> void:
	if crosshair_tween_inprogress: return
	
	var mat = ui_crosshair.material as ShaderMaterial
	if mat and mat.get_shader_parameter("alpha") == 1.0: return
	
	crosshair_tween_inprogress = true
	if crosshair_tween and crosshair_tween.is_running():
		crosshair_tween.kill()
	
	crosshair_tween = create_tween()
	crosshair_tween.tween_property(ui_crosshair.material, "shader_parameter/alpha", 1.0, crosshair_tween_duration)
	crosshair_tween.finished.connect(func(): crosshair_tween_inprogress = false)  # Use signal instead of await!

## Shows an instructor hint to the player. If one is being showed already, it will be replaced. Supports BBCode!
func show_instructor_hint(hint: String, time: float) -> void:
	print("asked to show instructor hint '%s' for %s s" % [hint, time])
	ShowInstructorHint.emit(hint, time)

## Hides the current instructor hint.
func hide_instructor_hint() -> void:
	HideInstructorHint.emit()
