extends Node
onready var GLOBAL = get_parent()

export var Path_table_choosePlayer : NodePath
onready var table_choosePlayer : ColorRect = get_node(Path_table_choosePlayer)
export var Path_button_startFight: NodePath
onready var button_startFight : TextureButton = get_node(Path_button_startFight)

onready var characterChooseButton : PackedScene = preload("res://Combat/CombatSlotChoose.tscn")

var pressedPlayerSlotIndex : int = -1

func _ready():
	set_process(false)
	setup_connections()
	setup_chooseButtons()
	setupEnemies()

func setup_connections() -> void:
	for character in GLOBAL.group_characters.get_children():
		character.connect("pressed",self,"pressPlayerSlot",[character.get_index()])

func setup_chooseButtons() -> void:
	for buttonRemove in table_choosePlayer.get_node("Characters").get_children():
		buttonRemove.queue_free()
	for characterName in Controller.charactersAvailableIDs:
		var button = characterChooseButton.instance()
		var character = Controller.findCharacter(characterName)
		button.connect("pressed",self,"pressChooseCharacterSlot",[character])
		button.get_node("Icon").texture = character.spriteFace
		button.get_node("Name").text = character.nameShown
		table_choosePlayer.get_node("Characters").add_child(button)

func setupEnemies() -> void:
	for i in range(3):
		if GLOBAL.encounter.enemies[i] == null:
			continue
		GLOBAL.enemies[i] = GLOBAL.encounter.enemies[i].duplicate()
		GLOBAL.group_enemies.get_child(i).get_node("Sprite").texture = GLOBAL.enemies[i].spriteIdle
		GLOBAL.enemies[i].healthCurrent = GLOBAL.enemies[i].healthMax
		GLOBAL.enemies[i].cooldownAbilityTotal = 1.0 / GLOBAL.enemies[i].speed

func setupCharacter(index : int) -> void:
	var character : Character = GLOBAL.characters[index]
	character.healthMax = character.healthBase
	character.strCurrent = character.strBase
	character.dexCurrent = character.dexBase
	character.intCurrent = character.intBase
	
	for i in range(character.inventorySlotCount):
		if character.inventory[i] == null:
			continue
		var item : Item = character.inventory[i]
		character.healthMax += item.healthBase
		character.strCurrent += item.strBase
		character.dexCurrent += item.dexBase
		character.intCurrent += item.intBase
	
	character.healthCurrent = character.healthMax
	character.cooldownAbilityTotal = 1.0 / character.speed
	
	character.abilityID = 0
	character.cooldownAbilityCurrent = 0.0
	character.dead = false

func pressPlayerSlot(index : int) -> void:
	table_choosePlayer.visible = true
	pressedPlayerSlotIndex = index

func pressChooseCharacterSlot(character : Character) -> void:
	var index = pressedPlayerSlotIndex
	table_choosePlayer.visible = false
	GLOBAL.characters[index] = character
	GLOBAL.group_characters.get_child(index).get_node("Sprite").texture = GLOBAL.characters[index].spriteIdle
	
	setupCharacter(index)
	button_startFight.visible = true
	
	Controller.charactersAvailableIDs.erase(character.id)
	Controller.charactersBusyIDs.append(character.id)
	setup_chooseButtons()

func startBattle() -> void:
	GLOBAL.state = GLOBAL.FIGHTING
	button_startFight.visible = false
	for i in range(GLOBAL.characterSlotCount):
		if GLOBAL.characters[i] != null:
			var character = GLOBAL.group_characters.get_child(i)
			character.get_node("HealthBar").visible = true
	for i in range(GLOBAL.enemySlotCount):
		if GLOBAL.enemies[i] != null:
			var enemy = GLOBAL.group_enemies.get_child(i)
			enemy.get_node("HealthBar").visible = true
	
	var midController = get_node("../MidBattleController")
	for character in GLOBAL.group_characters.get_children():
		character.disconnect("pressed",self,"pressPlayerSlot")
		character.connect("pressed",midController,"pressPlayerSlot",[character.get_index()])
	
	for button in GLOBAL.group_characters.get_children():
		button.self_modulate = Color(0.0,0.0,0.0,0.0)
	midController.startBattle()

func closeChoosePlayer():
	table_choosePlayer.visible = false

func clone(character : Character) -> Character:
	var clonedChar : Character = character.duplicate()
	clonedChar.abilities = [] + character.abilities
	return clonedChar


