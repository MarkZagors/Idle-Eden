extends TextureButton

export var encounter : Resource = null

func _ready():
	get_node("IconContainer/TextureRect").texture = encounter.icon

func gotoEncounter() -> void:
	Controller.transferEncounter = encounter
	var _err = get_tree().change_scene("res://Combat/Combat.tscn")
