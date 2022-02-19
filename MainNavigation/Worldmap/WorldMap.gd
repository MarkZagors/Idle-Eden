extends Control

func _ready():
	SavingManager.save_game()

func gotoArea(_viewport, event, _shape_idx, gotoScene):
	if event is InputEventMouseButton and event.pressed:
		var _err = get_tree().change_scene("res://Regions/"+ gotoScene +".tscn")

func enterArea(buttonName):
	var button : Area2D = get_node(buttonName)
	button.get_node("Hover").visible = true

func exitArea(buttonName):
	var button : Area2D = get_node(buttonName)
	button.get_node("Hover").visible = false

