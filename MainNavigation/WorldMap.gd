extends Control

func enterMouseStartingZone():
	var button : Area2D = get_node("StartingZone")
	button.get_node("Hover").visible = true

func exitMouseStartingZone():
	var button : Area2D = get_node("StartingZone")
	button.get_node("Hover").visible = false

func clickStartingZone(_viewport:Node,event:InputEvent,_indx:int):
	if event is InputEventMouseButton and event.pressed:
		var _err = get_tree().change_scene("res://Regions/StartingZone.tscn")


