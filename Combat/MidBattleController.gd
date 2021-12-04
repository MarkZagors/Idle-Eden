extends Node
onready var GLOBAL = get_parent()
onready var ATTACKING = get_node("AttackingController")

export var Path_group_consumables: NodePath
onready var group_consumables : HBoxContainer = get_node(Path_group_consumables)

var highestPriorityEnemyID : int = -1
var highestPriorityCharacterID : int = -1
var selectedPlayerSlotID : int = -1

var tickTimeCurrent : float = 0.0
var tickTimeMax : float = 0.5

var charEnemyArray : Array
var ended : bool = false

func _ready():
	set_process(false)

func _process(delta):
	if ended:
		return
#	Battle tikck
	for i in range(len(charEnemyArray)):
		var charEnemy = charEnemyArray[i]
		if charEnemy != null and charEnemy.dead == false:
			charEnemy.cooldownAbilityCurrent += delta
			if charEnemy.cooldownAbilityCurrent > charEnemy.cooldownAbilityTotal:
				charEnemy.cooldownAbilityCurrent = 0.0
				#Pay ability
				var node = null
				if charEnemy is Character:
					node = GLOBAL.group_characters.get_child(i)
				elif charEnemy is Enemy:
					node = GLOBAL.group_enemies.get_child(i-GLOBAL.characterSlotCount)
				if node == null:
					push_error("MidBattleController, playAbility() node is null")
				ATTACKING.playAbility(charEnemy,node)
				set_process(false)
				break
	GLOBAL.time += delta
	tickTimeCurrent += delta
	if tickTimeCurrent > tickTimeMax:
		ATTACKING.tickDamage()
		ATTACKING.uiUpdateHealth()
		tickTimeCurrent = 0.0

func startBattle() -> void:
	set_process(true)
	getPriority()
	charEnemyArray = GLOBAL.characters + GLOBAL.enemies
#	group_consumables.visible = true
	selectedPlayerSlotID = 0
	while true:
		if GLOBAL.characters[selectedPlayerSlotID] != null:
			break
		selectedPlayerSlotID += 1

func pressPlayerSlot(index : int) -> void:
	if GLOBAL.characters[index] != null:
		selectedPlayerSlotID = index

func checkWin() -> void:
	for i in range(GLOBAL.enemySlotCount):
		if GLOBAL.enemies[i] != null and GLOBAL.enemies[i].dead == false:
			return
	if GLOBAL.state == GLOBAL.FIGHTING:
#		Win battle
		ended = true
		get_node("../EndBattleController").win()
		set_process(false)
		GLOBAL.state = GLOBAL.END

func checkLose() -> void:
	for i in range(GLOBAL.characterSlotCount):
		if GLOBAL.characters[i] != null and GLOBAL.characters[i].dead == false:
			return
	if GLOBAL.state == GLOBAL.FIGHTING:
#		Lose battle
		ended = true
		get_node("../EndBattleController").lose()
		set_process(false)
		GLOBAL.state = GLOBAL.END

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
