extends Control

var encounterSelected : Encounter = null

#func gotoBattle1():
#	var _err = get_tree().change_scene("res://Combat/Combat.tscn")
#
func gotoWorldMap():
	var _err = get_tree().change_scene("res://MainNavigation/WorldMap.tscn")

func gotoEncounter() -> void:
	Controller.transferEncounter = encounterSelected
	var _err = get_tree().change_scene("res://Combat/Combat.tscn")

func endLock() -> void:
	print("end")
