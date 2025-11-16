@tool
## @entity PointClass
## @appearance iconsprite("editor/env_sky.vmt")
## Creates the default hardcoded world enviroment
class_name env_sky extends VMFEntityNode

@export var world_env_scene: PackedScene
var instance: WorldEnvironment

## @exposed
var meow: bool = true
