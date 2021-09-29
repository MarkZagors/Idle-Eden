extends Node
onready var GLOBAL = get_node("../..")
onready var MIDBATTLE = get_parent()

const HEALTH_TEMP_DECREASE = 50
const NODE_BACK_POSITION = 70

var currentNodeTimeout : TextureButton = null
var currentCharEnemyTimeout = null
var currentAbilityTimeout : Ability = null

func _process(delta):
	updateTempHealth(delta)

func playAbility(charEnemy,node) -> void:
	if GLOBAL.state == GLOBAL.END:
		return
	
	var ability : Ability = charEnemy.abilities[charEnemy.abilityID]
	currentAbilityTimeout = ability
	match ability.id:
		"slash":
			ability_slash(charEnemy)
		"smack":
			ability_smack(charEnemy)
		"bite":
			ability_enemy_bite()
	uiUpdateHealth()
	charEnemy.abilityID = (charEnemy.abilityID + 1) % charEnemy.abilitySlotCount
	
	node.get_node("Sprite").texture = charEnemy.spriteAttacking
	currentNodeTimeout = node
	currentCharEnemyTimeout = charEnemy
	GLOBAL.camera.zoom = Vector2(1,1)
	GLOBAL.background.get_node("HitFilter").visible = true
	if charEnemy is Character:
		node.get_node("Sprite").position.x += 50
	else:
		node.get_node("Sprite").position.x -= 50
	
	get_node("Timer").wait_time = 0.25
	get_node("Timer").start()

func uiUpdateHealth() -> void:
	for i in range(GLOBAL.enemySlotCount):
		if GLOBAL.enemies[i] != null:
			var enemy = GLOBAL.group_enemies.get_child(i)
			setHealth(enemy,GLOBAL.enemies[i])
	for i in range(GLOBAL.characterSlotCount):
		if GLOBAL.characters[i] != null:
			var character = GLOBAL.group_characters.get_child(i)
			setHealth(character,GLOBAL.characters[i])

func setHealth(node,charEnemy) -> void:
	node.get_node("HealthBar/HealthCurrent").rect_size.x = getHealthBarSize(charEnemy)
#	node.get_node("HealthBar/HealthTemp").rect_size.x = getHealthBarSize(charEnemy)

func getHealthBarSize(charEnemy) -> int:
	var ratio : float = float(charEnemy.healthCurrent) / float(charEnemy.healthMax)
	ratio = clamp(ratio,0.0,1.0)
	return int(ratio * 200)

func updateTempHealth(delta) -> void:
	for i in range(GLOBAL.enemySlotCount):
		if GLOBAL.enemies[i] != null:
			var enemyHpTemp = GLOBAL.group_enemies.get_child(i).get_node("HealthBar/HealthTemp")
			var enemyHpCurrent = GLOBAL.group_enemies.get_child(i).get_node("HealthBar/HealthCurrent")
			if enemyHpTemp.rect_size.x > enemyHpCurrent.rect_size.x:
				enemyHpTemp.rect_size.x -= delta * HEALTH_TEMP_DECREASE
	for i in range(GLOBAL.characterSlotCount):
		if GLOBAL.characters[i] != null:
			var characterHpTemp = GLOBAL.group_characters.get_child(i).get_node("HealthBar/HealthTemp")
			var characterHpCurrent = GLOBAL.group_characters.get_child(i).get_node("HealthBar/HealthCurrent")
			if characterHpTemp.rect_size.x > characterHpCurrent.rect_size.x:
				characterHpTemp.rect_size.x -= delta * HEALTH_TEMP_DECREASE
	pass

func damageEnemyPriority(damage : int) -> void:
	var enemy = GLOBAL.enemies[MIDBATTLE.highestPriorityEnemyID]
	enemy.healthCurrent -= damage
	if enemy.healthCurrent < 1:
		enemy.dead = true
		MIDBATTLE.getPriority()
		MIDBATTLE.checkWin()
	
	var node = GLOBAL.group_enemies.get_child(MIDBATTLE.highestPriorityEnemyID)
	animateDamage(node,damage)

func damageCharacterPriority(damage : int) -> void:
	var character = GLOBAL.characters[MIDBATTLE.highestPriorityCharacterID]
	character.healthCurrent -= damage
	if character.healthCurrent < 1:
		character.dead = true
		MIDBATTLE.getPriority()
		MIDBATTLE.checkLose()
	
	var node = GLOBAL.group_characters.get_child(MIDBATTLE.highestPriorityCharacterID)
	animateDamage(node,damage)

func animateDamage(node,damage) -> void:
	node.get_node("Sprite/AnimationPlayer").stop()
	node.get_node("Sprite/AnimationPlayer").play("Hit")
	node.get_node("HitSprite").texture = currentAbilityTimeout.hitSprite
	node.get_node("HitSprite/AnimationPlayer").play("Hit")
	node.get_node("DamageLabel/Label").text = str(damage)
	node.get_node("DamageLabel/AnimationPlayer").stop()
	node.get_node("DamageLabel/AnimationPlayer").play("Show")

func exitAttacking() -> void:
	currentNodeTimeout.get_node("Sprite").texture = currentCharEnemyTimeout.spriteIdle
	currentNodeTimeout.get_node("Sprite").position.x = NODE_BACK_POSITION
	
	get_node("Timer").stop()
	MIDBATTLE.set_process(true)
	
	currentNodeTimeout = null
	currentCharEnemyTimeout = null
	currentAbilityTimeout = null
	
	GLOBAL.camera.zoom = Vector2(1.0,1.0)
	GLOBAL.background.get_node("HitFilter").visible = false

func ability_slash(character : Character) -> void:
	var damage = character.strCurrent
	damageEnemyPriority(damage)

func ability_smack(character : Character) -> void:
	var damage = character.strCurrent * 3
	damageEnemyPriority(damage)

func ability_enemy_bite() -> void:
	damageCharacterPriority(1)
