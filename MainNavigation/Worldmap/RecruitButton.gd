extends TextureButton

export var recruitment : Resource

func _ready():
	get_node("IconContainer/TextureRect").texture = recruitment.character.spriteFace

func gotoRecruit():
	Controller.transferRecruit = recruitment
	var _err = get_tree().change_scene("res://MainNavigation/Recruitment/RecruitmentScreen.tscn")
	pass
