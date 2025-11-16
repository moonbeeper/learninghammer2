@tool
## @entity PointClass
## @base Targetname, Origin, Angles
## @appearance studio("models/props/screen.mdl")
## An entity that places an interactable screen on the world.
class_name prop_interactable_screen extends VMFEntityNode

# must include the trailing slash.
const SCREEN_RESOURCE_FOLDER: String = "res://resources/screen/"

@warning_ignore_start("unused_signal")

signal OnAction1()
signal OnAction2()
signal OnAction3()
signal OnAction4()

signal _OnPushAction1()
signal _OnPushAction2()
signal _OnPushAction3()
signal _OnPushAction4()

@warning_ignore_restore("unused_signal")

@export var viewport: SubViewport
@export var screen_root: InteractableScreen

var default_resource: InteractableScreenResource = preload("res://resources/screen/default.tres")

## The path to the screen resource without the extension. If not found, it will be using the default one
## @exposed
var resource_path: String = "default":
	get: return entity.get("resource_path")

func _entity_setup(_e: VMFEntity) -> void:
	var resource = get_resource(resource_path)
	var instance = resource.scene.instantiate()
	
	if resource.is_portrait:
		screen_root.set_portrait()
		# I was thinking of doing this on runtime but it wouldn't show up correctly in editor
		instance.rotation_degrees = -90
		instance.position = Vector2(0, 548)
		
	viewport.add_child(instance)
	instance.set_owner(get_owner())

func get_resource(resource_name: String) -> InteractableScreenResource:
	var path = SCREEN_RESOURCE_FOLDER + "%s.tres" % [resource_name]
	var resource = load(path)
	if resource is InteractableScreenResource:
		return resource
	print("Interactable screen resource wasn't found, using default one")
	return default_resource
	
func PushAction1(_param = null):
	_OnPushAction1.emit()

func PushAction2(_param = null):
	_OnPushAction2.emit()
	
func PushAction3(_param = null):
	_OnPushAction3.emit()
	
func PushAction4(_param = null):
	_OnPushAction4.emit()
	
