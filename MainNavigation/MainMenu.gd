extends Control

func newGame():
	Controller.addStartingCharacter()
	var _err = get_tree().change_scene("res://MainNavigation/WorldMap.tscn")

func loadGame():
	SavingManager.load_game()
	var _err = get_tree().change_scene("res://MainNavigation/WorldMap.tscn")
