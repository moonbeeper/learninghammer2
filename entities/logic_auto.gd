@tool
class_name logic_auto extends VMFEntityNode

signal OnMapSpawn()

const FLAG_REMOVE_ON_FIRE = 1; # naive me :)

func _entity_ready():
	trigger_output(OnMapSpawn)
	#if has_flag(FLAG_REMOVE_ON_FIRE): queue_free()
