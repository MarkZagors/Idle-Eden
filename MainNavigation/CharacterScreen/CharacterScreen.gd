extends Control
onready var character : Character = Controller.transferCharacter

export var Path_group_items : NodePath
onready var group_items : Control = get_node(Path_group_items)
export var Path_group_abilities : NodePath
onready var group_abilities : Control = get_node(Path_group_abilities)
export var Path_group_info : NodePath
onready var group_info : Control = get_node(Path_group_info)
export var Path_group_buttons : NodePath
onready var group_buttons : Control = get_node(Path_group_buttons)
export var Path_group_bg: NodePath
onready var group_bg : Control = get_node(Path_group_bg)
export var Path_upperpoint : NodePath
onready var upperpoint : Control = get_node(Path_upperpoint)
export var Path_levelCircle : NodePath
onready var levelCircle : Control = get_node(Path_levelCircle)

onready var slotObj = preload("res://MainNavigation/Slot.tscn")
onready var slotNormalTexture : Texture = preload("res://SPRITES/UI/SlotNormal1.png")
onready var slotPickedAllTexture : Texture = preload("res://SPRITES/UI/SlotPickedAll.png")
onready var slotPickedCurrentTexture : Texture = preload("res://SPRITES/UI/SlotPickedCurrent.png")

onready var startingPosAbilities : Vector2 = group_abilities.get_node("CurrentAbilities").rect_position
onready var startingPosItems : Vector2 = group_items.get_node("CurrentItems").rect_position

var abilitySlotPressedCurrent : int = -1
var abilitySlotPressedAll : int = -1
var itemSlotPressedCurrent : int = -1
var itemSlotPressedAll : int = -1

enum {
	MAIN,
	ITEMS,
	ABILITIES,
	LEVELREWARDS,
	STATS
}

var state : int = MAIN

func _ready():
	Controller.transferCharacter = null
#	Controller.connect("inventory_restructure_add",self,"onRestructureAdd")
#	Controller.connect("inventory_restructure_remove",self,"onRestructureRemove")
	setupItems()
	setupAbilities()
	setupInfo()
	setupLevel()

func setupItems() -> void:
	for i in range(character.inventorySlotCount):
		var slot = slotObj.instance()
		var item : Item = character.inventory[i]
		if item != null:
			slot.get_node("Sprite").texture = item.icon
		slot.connect("pressed",self,"openItems",[i])
		group_items.get_node("CurrentItems").add_child(slot)
	setupItemsAll()

func setupItemsAll() -> void:
	for i in range(len(Controller.inventory)):
		var allItem : Item = Controller.inventory[i]
		if allItem.type == Controller.ITEM_TYPE_EQUIPPABLE:
			var slot = slotObj.instance()
			var ammount : int = allItem.ammount
			slot.get_node("Sprite").texture = allItem.icon
			if ammount > 1:
				slot.get_node("Ammount").visible = true
				slot.get_node("Ammount/Label").text = str(ammount)
			slot.connect("pressed",self,"clickAllItem",[i])
			group_items.get_node("ItemGrid/GridContainer").add_child(slot)

func setupAbilities() -> void:
	for i in range(character.abilitySlotCount):
		var slot = slotObj.instance()
		var ability : Ability = character.abilities[i]
		if ability != null:
			slot.get_node("Sprite").texture = ability.icon
		slot.connect("pressed",self,"openAbilities",[i])
		group_abilities.get_node("CurrentAbilities").add_child(slot)
	for i in range(len(character.abilityAll)):
		var slot = slotObj.instance()
		var ability : Ability = character.abilityAll[i]
		if ability != null:
			slot.get_node("Sprite").texture = ability.icon
		slot.connect("pressed",self,"clickAllAbility",[i])
		group_abilities.get_node("AbilityGrid/GridContainer").add_child(slot)

func setupInfo() -> void:
	group_bg.get_node("NameLabel").text = character.nameShown
	group_bg.get_node("CharacterSprite").texture = character.spriteIdle

func setupLevel() -> void:
	levelCircle.get_node("Label").text = str(character.level)
	levelCircle.get_node("LevelProgress").value = character.xpCurrent
	levelCircle.get_node("LevelProgress").min_value = character.xpAll[character.level-1]
	levelCircle.get_node("LevelProgress").max_value = character.xpAll[character.level]

func backButton() -> void:
	match state:
		MAIN:
			var _err = get_tree().change_scene("res://MainNavigation/CharacterChooseScreen.tscn")
		ABILITIES:
			backToMain()
		ITEMS:
			backToMain()

func openItems(index : int) -> void:
	if state != ITEMS:
		group_items.get_node("CurrentItems").rect_position = upperpoint.rect_position
		group_buttons.visible = false
		group_abilities.get_node("CurrentAbilities").visible = false
		group_bg.get_node("CharacterSprite").visible = false
		group_items.get_node("ItemGrid").visible = true
		group_bg.get_node("NameLabel").visible = false
	
	state = ITEMS
	clickCurrentItem(index)

func clickCurrentItem(index : int) -> void:
	var item : Item = character.inventory[index]
	group_info.get_node("AbilityDescription").visible = true
	group_info.get_node("AbilityNameLabel").visible = true
	group_info.get_node("InfoBG").visible = true
	group_info.get_node("EquipButton").visible = false
	
	if item != null:
		group_info.get_node("AbilityDescription").bbcode_text = item.description
		group_info.get_node("AbilityNameLabel").text = item.nameShown
	else:
		group_info.get_node("AbilityNameLabel").text = "Empty space"
		group_info.get_node("AbilityDescription").visible = false
	itemSlotPressedCurrent = index
	itemSlotPressedAll = -1
	setSlotColorItem()

func clickAllItem(index : int) -> void:
	var item : Item = Controller.inventory[index]
	group_info.get_node("AbilityDescription").bbcode_text = item.description
	group_info.get_node("AbilityDescription").visible = true
	group_info.get_node("AbilityNameLabel").text = item.nameShown
	group_info.get_node("EquipButton").visible = true
	itemSlotPressedAll = index
	setSlotColorItem()

func setSlotColorItem() -> void:
	resetSlotColorItem()
	if itemSlotPressedCurrent != -1:
		var slot = group_items.get_node("CurrentItems").get_child(itemSlotPressedCurrent)
		slot.texture_normal = slotPickedCurrentTexture
	if itemSlotPressedAll != -1:
		var slot = group_items.get_node("ItemGrid/GridContainer").get_child(itemSlotPressedAll)
		slot.texture_normal = slotPickedAllTexture

func resetSlotColorItem() -> void:
	for slot in group_items.get_node("CurrentItems").get_children():
		slot.texture_normal = slotNormalTexture
	for slot in group_items.get_node("ItemGrid/GridContainer").get_children():
		slot.texture_normal = slotNormalTexture

func updateItems() -> void:
	var grid : GridContainer = group_items.get_node("ItemGrid/GridContainer")
	for i in range(grid.get_child_count()):
		grid.get_child(i).queue_free()
	setupItemsAll()

func openAbilities(index : int) -> void:
	if state != ABILITIES:
		group_abilities.get_node("CurrentAbilities").rect_position = upperpoint.rect_position
		group_buttons.visible = false
		group_items.get_node("CurrentItems").visible = false
		group_bg.get_node("CharacterSprite").visible = false
		group_abilities.get_node("AbilityGrid").visible = true
		group_bg.get_node("NameLabel").visible = false
	
	state = ABILITIES
	clickCurrentAbility(index)

func clickCurrentAbility(index : int) -> void:
	var ability : Ability = character.abilities[index]
	group_info.get_node("AbilityDescription").visible = true
	group_info.get_node("AbilityNameLabel").visible = true
	group_info.get_node("InfoBG").visible = true
	group_info.get_node("AbilityDescription").bbcode_text = ability.description
	group_info.get_node("AbilityNameLabel").text = ability.nameShown
	group_info.get_node("EquipButton").visible = false
	abilitySlotPressedCurrent = index
	abilitySlotPressedAll = -1
	setSlotColorAbility()

func clickAllAbility(index : int) -> void:
	var ability : Ability = character.abilityAll[index]
	group_info.get_node("AbilityDescription").bbcode_text = ability.description
	group_info.get_node("AbilityNameLabel").text = ability.nameShown
	group_info.get_node("EquipButton").visible = true
	abilitySlotPressedAll = index
	setSlotColorAbility()

func setSlotColorAbility() -> void:
	resetSlotColorAbility()
	if abilitySlotPressedCurrent != -1:
		var slot = group_abilities.get_node("CurrentAbilities").get_child(abilitySlotPressedCurrent)
		slot.texture_normal = slotPickedCurrentTexture
	if abilitySlotPressedAll != -1:
		var slot = group_abilities.get_node("AbilityGrid/GridContainer").get_child(abilitySlotPressedAll)
		slot.texture_normal = slotPickedAllTexture

func resetSlotColorAbility() -> void:
	for slot in group_abilities.get_node("CurrentAbilities").get_children():
		slot.texture_normal = slotNormalTexture
	for slot in group_abilities.get_node("AbilityGrid/GridContainer").get_children():
		slot.texture_normal = slotNormalTexture

func actionPressed() -> void:
	match state:
		ABILITIES:
			character.abilities[abilitySlotPressedCurrent] = character.abilityAll[abilitySlotPressedAll]
			var slot : TextureButton = group_abilities.get_node("CurrentAbilities").get_child(abilitySlotPressedCurrent)
			slot.get_node("Sprite").texture = character.abilities[abilitySlotPressedCurrent].icon
		ITEMS:
			var currentItem : Item = character.inventory[itemSlotPressedCurrent] 
			if currentItem != null:
				Controller.addItem(currentItem)
			character.inventory[itemSlotPressedCurrent] = Controller.inventory[itemSlotPressedAll]
			var slot : TextureButton = group_items.get_node("CurrentItems").get_child(itemSlotPressedCurrent)
			slot.get_node("Sprite").texture = character.inventory[itemSlotPressedCurrent].icon
			Controller.removeItemIndex(itemSlotPressedAll,1)
			clickCurrentItem(itemSlotPressedCurrent)
			updateItems()

func backToMain() -> void:
	group_info.get_node("AbilityDescription").visible = false
	group_info.get_node("AbilityNameLabel").visible = false
	group_info.get_node("InfoBG").visible = false
	group_abilities.get_node("AbilityGrid").visible = false
	group_items.get_node("ItemGrid").visible = false
	group_info.get_node("EquipButton").visible = false
	group_abilities.get_node("CurrentAbilities").visible = true
	group_abilities.get_node("CurrentAbilities").rect_position = startingPosAbilities
	group_items.get_node("CurrentItems").rect_position = startingPosItems
	group_items.get_node("CurrentItems").visible = true
	group_bg.get_node("CharacterSprite").visible = true
	group_bg.get_node("NameLabel").visible = true
	group_buttons.visible = true
	state = MAIN
	resetSlotColorItem()
	resetSlotColorAbility()

func onRestructureAdd() -> void:
	print("added")

func onRestructureRemove() -> void:
	print("removed")
