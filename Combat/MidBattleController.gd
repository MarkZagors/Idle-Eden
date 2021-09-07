extends Node
onready var GLOBAL = get_parent()
onready var ATTACKING = get_node("AttackingController")

var highestPriorityEnemyID : int = -1
var highestPriorityCharacterID : int = -1
var selecterPlayerSlotID : int = -1

var charEnemyArray : Array

func _ready():
	set_process(false)

func _process(delta):
	battleTick(delta)

func startBattle() -> void:
	set_process(true)
	getPriority()
	charEnemyArray = GLOBAL.characters + GLOBAL.enemies
	selecterPlayerSlotID = 0

func battleTick(delta) -> void:
	for i in range(len(charEnemyArray)):
		var charEnemy = charEnemyArray[i]
		if charEnemy != null and charEnemy.dead == false:
			charEnemy.cooldownAbilityCurrent += delta
			if charEnemy.cooldownAbilityCurrent > charEnemy.cooldownAbilityTotal:
				charEnemy.cooldownAbilityCurrent = 0.0
				playAbility(charEnemy,i)
				break

func playAbility(charEnemy,index) -> void:
	var node = null
	if charEnemy is Character:
		node = GLOBAL.group_characters.get_child(index)
	elif charEnemy is Enemy:
		node = GLOBAL.group_enemies.get_child(index-GLOBAL.characterSlotCount)
	if node == null:
		push_error("MidBattleController, playAbility() node is null")
	ATTACKING.playAbility(charEnemy,node)
	set_process(false)

func pressPlayerSlot(index : int) -> void:
	selecterPlayerSlotID = index

func getPriority() -> void:
	var maxPriority = -1
	for i in range(GLOBAL.enemySlotCount):
		var enemy = GLOBAL.enemies[i]
		if enemy != null and enemy.dead == false:
			if enemy.priority > maxPriority:
				maxPriority = enemy.priority
				highestPriorityEnemyID = i
	maxPriority = -1
	for i in range(GLOBAL.characterSlotCount):
		var character = GLOBAL.characters[i]
		if character != null and character.dead == false:
			if character.priority > maxPriority:
				maxPriority = character.priority
				highestPriorityCharacterID = i

func checkWin() -> void:
	for i in range(GLOBAL.enemySlotCount):
		if GLOBAL.enemies[i] != null and GLOBAL.enemies[i].dead == false:
			return
	if GLOBAL.state == GLOBAL.FIGHTING:
		winBattle()

func checkLose() -> void:
	for i in range(GLOBAL.characterSlotCount):
		if GLOBAL.characters[i] != null and GLOBAL.characters[i].dead == false:
			return
	if GLOBAL.state == GLOBAL.FIGHTING:
		loseBattle()

func winBattle() -> void:
	get_node("../EndBattleController").win()
	set_process(false)
	GLOBAL.state = GLOBAL.END

func loseBattle() -> void:
	get_node("../EndBattleController").lose()
	set_process(false)
	GLOBAL.state = GLOBAL.END

