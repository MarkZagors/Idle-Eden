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
export var Path_group_rewards : NodePath
onready var group_rewards : VBoxContainer = get_node(Path_group_rewards)
export var Path_button_stats : NodePath
onready var button_stats : Button = get_node(Path_button_stats)

onready var slotObj = preload("res://MainNavigation/InventoryScreen/Slot.tscn")
onready var slotNormalTexture : Texture = preload("res://SPRITES/UI/SlotNormal1.png")
onready var slotPickedAllTexture : Texture = preload("res://SPRITES/UI/SlotPickedAll.png")
onready var slotPickedCurrentTexture : Texture = preload("res://SPRITES/UI/SlotPickedCurrent.png")
onready var rewardSlot = preload("res://MainNavigation/CharacterScreen/Reward.tscn")

onready var startingPosAbilities : Vector2 = group_abilities.get_node("CurrentAbilities").rect_position
onready var startingPosItems : Vector2 = group_items.get_node("CurrentItems").rect_position

var abilitySlotPressedCurrent : int = -1
var abilitySlotPressedAll : int = -1
var itemSlotPressedCurrent : int = -1
var itemSlotPressedAll : int = -1
var statsOpened : bool = false

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
	#Setup items
	for i in range(character.inventorySlotCount):
		var slot = slotObj.instance()
		var item : Item = character.inventory[i]
		if item != null:
			slot.get_node("Sprite").texture = item.icon
		slot.connect("pressed",self,"openItems",[i])
		group_items.get_node("CurrentItems").add_child(slot)
	setupItemsAll()
	#Setup Abilities
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
	#Setup Info
	group_bg.get_node("NameLabel").text = character.nameShown
	group_bg.get_node("CharacterSprite").texture = character.spriteIdle
	#Setup level
	levelCircle.get_node("Label").text = str(character.level)
	levelCircle.get_node("LevelProgress").value = character.xpCurrent
	levelCircle.get_node("LevelProgress").min_value = character.xpAll[character.level-1]
	levelCircle.get_node("LevelProgress").max_value = character.xpAll[character.level]
	#Setup level rewards
	for reward in character.rewards:
		var rewSlot = rewardSlot.instance()
		rewSlot.get_node("Name").text = reward.name
		rewSlot.get_node("Level").text = "Lv. " + str(reward.level)
		rewSlot.get_node("Icon").texture = reward.icon
		
		if character.level >= reward.level:
			rewSlot.color = Color("47302e")
		
		group_rewards.add_child(rewSlot)

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

func backButton() -> void:
	match state:
		MAIN:
			var _err = get_tree().change_scene("res://MainNavigation/CharacterChooseScreen/CharacterChooseScreen.tscn")
		ABILITIES, ITEMS:
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
			group_info.get_node("RemoveButton").visible = false
			levelCircle.get_node("Label").visible = true
			levelCircle.get_node("Icon").visible = false
			group_buttons.visible = true
			button_stats.visible = true
			statsOpened = false
			state = MAIN
			resetSlotColorItem()
			resetSlotColorAbility()
		LEVELREWARDS:
			group_abilities.visible = true
			group_items.visible = true
			group_buttons.visible = true
			group_rewards.visible = false
			state = MAIN

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
	button_stats.visible = false

func clickCurrentItem(index : int) -> void:
	var item : Item = character.inventory[index]
	group_info.get_node("AbilityDescription").visible = true
	group_info.get_node("AbilityNameLabel").visible = true
	group_info.get_node("InfoBG").visible = true
	group_info.get_node("EquipButton").visible = false
	levelCircle.get_node("Label").visible = false
	levelCircle.get_node("Icon").visible = true
	
	if item != null:
		group_info.get_node("AbilityDescription").bbcode_text = item.fullDescription()
		group_info.get_node("AbilityNameLabel").text = item.nameShown
		group_info.get_node("RemoveButton").visible = true
		levelCircle.get_node("Icon").texture = item.icon
	else:
		group_info.get_node("AbilityNameLabel").text = "Empty space"
		group_info.get_node("AbilityDescription").visible = false
		group_info.get_node("RemoveButton").visible = false
		levelCircle.get_node("Icon").texture = null
	itemSlotPressedCurrent = index
	itemSlotPressedAll = -1
	setSlotColorItem()

func clickAllItem(index : int) -> void:
	var item : Item = Controller.inventory[index]
	group_info.get_node("AbilityDescription").bbcode_text = item.fullDescription()
	group_info.get_node("AbilityDescription").visible = true
	group_info.get_node("AbilityNameLabel").text = item.nameShown
	group_info.get_node("EquipButton").visible = true
	group_info.get_node("RemoveButton").visible = false
	levelCircle.get_node("Icon").texture = item.icon
	itemSlotPressedAll = index
	setSlotColorItem()

func setSlotColorItem() -> void:
	resetSlotColorItem()
	var childCountCurrent = group_items.get_node("CurrentItems").get_child_count()
	var childCountAll = group_items.get_node("ItemGrid/GridContainer").get_child_count()
	#TODO FIX THE BUG ?????
	if itemSlotPressedCurrent != -1 and itemSlotPressedCurrent < childCountCurrent:
		var slot = group_items.get_node("CurrentItems").get_child(itemSlotPressedCurrent)
		slot.texture_normal = slotPickedCurrentTexture
	if itemSlotPressedAll != -1 and itemSlotPressedAll < childCountAll:
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
	button_stats.visible = false

func clickCurrentAbility(index : int) -> void:
	var ability : Ability = character.abilities[index]
	group_info.get_node("AbilityDescription").visible = true
	group_info.get_node("AbilityNameLabel").visible = true
	group_info.get_node("InfoBG").visible = true
	group_info.get_node("AbilityDescription").bbcode_text = ability.description
	group_info.get_node("AbilityNameLabel").text = ability.nameShown
	group_info.get_node("EquipButton").visible = false
	levelCircle.get_node("Label").visible = false
	levelCircle.get_node("Icon").texture = ability.icon
	levelCircle.get_node("Icon").visible = true
	abilitySlotPressedCurrent = index
	abilitySlotPressedAll = -1
	setSlotColorAbility()

func clickAllAbility(index : int) -> void:
	var ability : Ability = character.abilityAll[index]
	group_info.get_node("AbilityDescription").bbcode_text = ability.description
	group_info.get_node("AbilityNameLabel").text = ability.nameShown
	group_info.get_node("EquipButton").visible = true
	levelCircle.get_node("Icon").texture = ability.icon
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
			if checkUniqueAbility():
				return
			character.abilities[abilitySlotPressedCurrent] = character.abilityAll[abilitySlotPressedAll]
			var slot : TextureButton = group_abilities.get_node("CurrentAbilities").get_child(abilitySlotPressedCurrent)
			slot.get_node("Sprite").texture = character.abilities[abilitySlotPressedCurrent].icon
		ITEMS:
			var currentItem : Item = character.inventory[itemSlotPressedCurrent] 
			if currentItem != null:
				Controller.addItem(currentItem,1)
			character.inventory[itemSlotPressedCurrent] = Controller.inventory[itemSlotPressedAll]
			var slot : TextureButton = group_items.get_node("CurrentItems").get_child(itemSlotPressedCurrent)
			slot.get_node("Sprite").texture = character.inventory[itemSlotPressedCurrent].icon
			Controller.removeItemIndex(itemSlotPressedAll,1)
			clickCurrentItem(itemSlotPressedCurrent)
			updateItems()

func checkUniqueAbility() -> bool:
	var abilityChosen : Ability = character.abilityAll[abilitySlotPressedAll]
	
	if abilityChosen.unique:
		for index in len(character.abilities):
			if character.abilities[index].id == abilityChosen.id:
				character.abilities[index] = character.abilities[abilitySlotPressedCurrent]
				var slotSwap : TextureButton = group_abilities.get_node("CurrentAbilities").get_child(index)
				slotSwap.get_node("Sprite").texture = character.abilities[index].icon
				break
		character.abilities[abilitySlotPressedCurrent] = abilityChosen
		var slot : TextureButton = group_abilities.get_node("CurrentAbilities").get_child(abilitySlotPressedCurrent)
		slot.get_node("Sprite").texture = character.abilities[abilitySlotPressedCurrent].icon
		return true
	
	return false

func removeItem() -> void:
	var currentItem : Item = character.inventory[itemSlotPressedCurrent]
	var slot : TextureButton = group_items.get_node("CurrentItems").get_child(itemSlotPressedCurrent)
	character.inventory[itemSlotPressedCurrent] = null
	Controller.addItem(currentItem,1)
	slot.get_node("Sprite").texture = null
	clickCurrentItem(itemSlotPressedCurrent)
	updateItems()

func openLevelRewards() -> void:
	group_abilities.visible = false
	group_items.visible = false
	group_buttons.visible = false
	state = LEVELREWARDS
	
	group_rewards.visible = true

func openStats() -> void:
	if not statsOpened:
		statsOpened = true
		group_info.get_node("InfoBG").visible = true
		group_info.get_node("AbilityNameLabel").visible = true
		group_info.get_node("AbilityNameLabel").text = "Stats"
		group_info.get_node("AbilityDescription").visible = true
		group_info.get_node("AbilityDescription").bbcode_text = """Health : %s
[color=#d6463a]Strength : %s[/color]
[color=#96f783]Dextirity : %s[/color]
[color=#4eb6f2]Intelligence : %s[/color]
""" % getStats()
		group_bg.get_node("CharacterSprite").visible = false
	else:
		statsOpened = false
		group_info.get_node("InfoBG").visible = false
		group_info.get_node("AbilityNameLabel").visible = false
		group_info.get_node("AbilityDescription").visible = false
		group_bg.get_node("CharacterSprite").visible = true

func getStats():
	var health : int = character.healthBase
	var stren : int = character.strBase
	var dex : int = character.dexBase
	var intel : int = character.intBase
	for item in character.inventory:
		if item != null:
			health += item.healthBase
			stren += item.strBase
			dex += item.dexBase
			intel += item.intBase
	return [health, stren, dex, intel]
