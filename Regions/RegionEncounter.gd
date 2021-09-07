extends Button

export var encounter : Resource = null

func gotoEncounter() -> void:
	Controller.transferEncounter = encounter
	var _err = get_tree().change_scene("res://Combat/Combat.tscn")
