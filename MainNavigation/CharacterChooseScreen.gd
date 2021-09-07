extends Control

export var Path_group_characters : NodePath
onready var group_characters : GridContainer = get_node(Path_group_characters)

onready var charButtonScene = preload("res://MainNavigation/CharacterChooseButton.tscn")

func _ready():
	for i in range(len(Controller.characters)):
		var character : Character = Controller.characters[i]
		var charButton : TextureButton = charButtonScene.instance()
		var _err = charButton.connect("pressed",self,"gotoCharScreen",[Controller.characters[i]])
		charButton.get_node("Icon").texture = character.spriteFace
		charButton.get_node("Name").text = character.nameShown
		
		group_characters.add_child(charButton)

func backToMain() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/WorldMap.tscn")

func gotoInventory() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/InventoryScreen.tscn")

func gotoCharScreen(character : Character) -> void:
	Controller.transferCharacter = character
	var _err = get_tree().change_scene("res://MainNavigation/CharacterScreen/CharacterScreen.tscn")
	pass
