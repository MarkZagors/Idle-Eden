extends Node
onready var GLOBAL = get_parent()

export var Path_table_choosePlayer : NodePath
onready var table_choosePlayer : ColorRect = get_node(Path_table_choosePlayer)
export var Path_button_startFight: NodePath
onready var button_startFight : Button = get_node(Path_button_startFight)

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
	for character in Controller.characters:
		var button = characterChooseButton.instance()
		button.get_node("AcceptButton").connect("pressed",self,"pressChooseCharacterSlot",[character])
		table_choosePlayer.get_node("Characters").add_child(button)

func setupEnemies() -> void:
	for i in range(3):
		if Controller.transferEncounter.enemies[i] == null:
			continue
		GLOBAL.enemies[i] = Controller.transferEncounter.enemies[i].duplicate()
		GLOBAL.group_enemies.get_child(i).get_node("Sprite").texture = GLOBAL.enemies[i].spriteIdle
	Controller.transferEncounter = null

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
	pass

func pressPlayerSlot(index : int) -> void:
	table_choosePlayer.visible = true
	pressedPlayerSlotIndex = index

func pressChooseCharacterSlot(character : Character) -> void:
	var index = pressedPlayerSlotIndex
	table_choosePlayer.visible = false
	GLOBAL.characters[index] = clone(character)
	GLOBAL.group_characters.get_child(index).get_node("Sprite").texture = GLOBAL.characters[index].spriteIdle
	
	setupCharacter(index)
	button_startFight.visible = true

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
	midController.startBattle()

func clone(character : Character) -> Character:
	var clonedChar : Character = character.duplicate()
	clonedChar.abilities = [] + character.abilities
	return clonedChar
