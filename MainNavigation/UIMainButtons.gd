extends Control

func backToMain() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/WorldMap.tscn")

func gotoCharacter() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/CharacterChooseScreen/CharacterChooseScreen.tscn")

func gotoInventory() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/InventoryScreen/InventoryScreen.tscn")

func gotoCrafting() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/CraftingScreen/CraftingScreen.tscn")
