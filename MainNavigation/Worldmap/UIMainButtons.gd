extends Control

func backToMain() -> void:
	Controller.changeScene("current")

func gotoCharacter() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/CharacterChooseScreen/CharacterChooseScreen.tscn")

func gotoInventory() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/InventoryScreen/InventoryScreen.tscn")

func gotoCrafting() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/CraftingScreen/CraftingScreen.tscn")
