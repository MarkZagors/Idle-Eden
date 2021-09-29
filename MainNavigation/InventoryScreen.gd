extends Control
var inventory = Controller.inventory

export var Path_group_items : NodePath
onready var group_items : GridContainer = get_node(Path_group_items)
export var Path_group_info : NodePath
onready var group_info : Control = get_node(Path_group_info)

onready var slotObj = preload("res://MainNavigation/Slot.tscn")

func _ready():
	setupItems()

func setupItems() -> void:
	for i in range(len(inventory)):
		var slot = slotObj.instance()
		var ammount = inventory[i].ammount
		slot.get_node("Sprite").texture = inventory[i].icon
		if ammount > 1:
			slot.get_node("Ammount").visible = true
			slot.get_node("Ammount/Label").text = str(ammount)
		slot.connect("pressed",self,"showInfo",[inventory[i]])
		group_items.add_child(slot)

func showInfo(item : Item) -> void:
	group_info.get_node("NameLabel").text = item.nameShown
	group_info.get_node("Description").bbcode_text = item.description
	group_info.get_node("CircleIcon/Icon").texture = item.icon
	match item.type:
		Controller.ITEM_TYPE_COMMON:
			group_info.get_node("ActionButton").visible = false
		Controller.ITEM_TYPE_EQUIPPABLE:
			group_info.get_node("ActionButton").visible = false

func pressAction() -> void:
	pass

func backToMain() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/WorldMap.tscn")

func gotoCharacterChooseScreen() -> void:
	var _err = get_tree().change_scene("res://MainNavigation/CharacterChooseScreen.tscn")

