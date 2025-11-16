@tool
class_name info_player_start extends VMFEntityNode

@export var player_scene: PackedScene
var instance: Player

## @exposed
var should_add_child: bool = true
func _entity_ready() -> void:
	if Player.INSTANCE: should_add_child = false
	instance = Player.INSTANCE if Player.INSTANCE else player_scene.instantiate()
	
	if should_add_child:
		get_tree().current_scene.add_child(instance);
	instance.global_transform = global_transform;
	instance.basis *= Basis.IDENTITY.rotated(Vector3.UP, PI * -0.5);
	get_parent().remove_child(self);
