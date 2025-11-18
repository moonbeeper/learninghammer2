@tool
## @entity PointClass
## @base Targetname, Origin, Angles
## @appearance studio("models/props/screen.mdl")
## An entity that places an interactable screen on the world.
class_name prop_interactable_screen extends VMFEntityNode

# must include the trailing slash.
const SCREEN_RESOURCE_FOLDER: String = "res://resources/screen/"

@warning_ignore_start("unused_signal")

# sadly, i cannot merge all of these into one.
# These actions are outputs that can be used in hammer io logic. Can be called from the screen UI
signal OnAction1()
signal OnAction2()
signal OnAction3()
signal OnAction4()

signal _InternalCallAction(action: String) 

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
	var instance_ui = resource.scene.instantiate()
	
	if resource.is_portrait:
		screen_root.is_portrait = true
		# I was thinking of doing this on runtime but it wouldn't show up correctly in editor
		instance_ui.rotation_degrees = -90
		instance_ui.position = Vector2(0, 548)
		
	viewport.add_child(instance_ui)
	instance_ui.set_owner(get_owner())

func get_resource(resource_name: String) -> InteractableScreenResource:
	var path = SCREEN_RESOURCE_FOLDER + "%s.tres" % [resource_name]
	var resource = load(path)
	if resource is InteractableScreenResource:
		return resource
	print("Requested interactable screen resource wasn't found, using default one")
	return default_resource
	
# must be "string" or else the generated fdg will have an incorrect type
func CallAction(string: String) -> void:  
	print("prop interactable screen '%s' is getting this action %s called" % [name, string])
	_InternalCallAction.emit(string)
