@tool
## @entity PointClass
## @base Targetname
## @appearance iconsprite("editor/env_instructor_hint.vmt")
## Shows an instructor hint to the player HUD
class_name env_instructor_hint extends VMFEntityNode

signal CaptionShown()
signal CaptionHidden()

## The caption to be showed in the player's HUD
## @exposed
var caption: String = "hello":
	get: return entity.get("caption", "hello")

## The caption timeout. May be set to -1.0 to have no timeout
## @exposed
var timeout: float = 3.0:
	get: return entity.get("timeout", 3.0)

func StartHint(_param = null):
	print("map IO wants to show a instructor hint")
	Player.INSTANCE.show_instructor_hint(caption, timeout)
	# apparently you can just give the signal to the method
	trigger_output(CaptionShown)

func HideHint(_param = null):
	print("map IO wants to hide a instructor hint")
	Player.INSTANCE.hide_instructor_hint()
	trigger_output(CaptionHidden)
