extends Node
onready var GLOBAL = get_node("../..")
onready var MIDBATTLE = get_parent()

const HEALTH_TEMP_DECREASE = 50
const NODE_BACK_POSITION = 70

var currentNodeTimeout : TextureButton = null
var currentCharEnemyTimeout = null
var currentAbilityTimeout : Ability = null

func _process(delta):
	#Update temp health
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

func playAbility(charEnemy,node) -> void:
	if GLOBAL.state == GLOBAL.END:
		return
	
#	node.get_node("Sprite").texture = charEnemy.spriteAttacking #CHANGE THIS LATER
	currentNodeTimeout = node
	currentCharEnemyTimeout = charEnemy
	GLOBAL.camera.zoom = Vector2(1,1)
	GLOBAL.background.get_node("HitFilter").visible = true
	if charEnemy is Character:
		node.get_node("Sprite").position.x += 50
		node.get_node("Sprite").texture = charEnemy.spriteAttacking
	else:
		node.get_node("Sprite").position.x -= 50
		node.get_node("Sprite").animation = "attack"
	
	var ability : Ability = charEnemy.abilities[charEnemy.abilityID]
	currentAbilityTimeout = ability
	match ability.id:
		"poisonedNail":
			ability_posionedNail(charEnemy)
		"extract":
			ability_extract(charEnemy)
		"miseryLovesCompany":
			ability_miseryLovesCompany(charEnemy)
		"bite":
			ability_enemy_bite(charEnemy)
		_:
			push_error("NO ABILITY ID FOUND: " + str(ability.id))
	
	uiUpdateHealth()
	charEnemy.abilityID = (charEnemy.abilityID + 1) % charEnemy.abilitySlotCount
	
	get_node("Timer").wait_time = 0.25
	get_node("Timer").start()

func getHealthBarSize(charEnemy) -> int:
	var ratio : float = float(charEnemy.healthCurrent) / float(charEnemy.healthMax)
	ratio = clamp(ratio,0.0,1.0)
	return int(ratio * 200)

func damageEnemyPriority(damage : int) -> void:
	var enemy : Enemy = GLOBAL.enemies[MIDBATTLE.highestPriorityEnemyID]
	enemy.healthCurrent -= damage
	var node = GLOBAL.group_enemies.get_child(MIDBATTLE.highestPriorityEnemyID)
	animateDamage(node,damage)
	if enemy.healthCurrent < 1:
		nodeDead(enemy, node)
	
func damageCharacterPriority(damage : int) -> void:
	var character : Character = GLOBAL.characters[MIDBATTLE.highestPriorityCharacterID]
	character.healthCurrent -= damage
	var node = GLOBAL.group_characters.get_child(MIDBATTLE.highestPriorityCharacterID)
	animateDamage(node,damage)
	if character.healthCurrent < 1:
		nodeDead(character, node)

func tickDamage() -> void:
	for i in range(len(GLOBAL.enemies)):
		if GLOBAL.enemies[i] == null:
			continue
		var enemy : Enemy = GLOBAL.enemies[i]
		enemy.healthCurrent -= int(enemy.poisonStack / 2.0)
		if enemy.healthCurrent < 1:
			var node = GLOBAL.group_enemies.get_child(i)
			nodeDead(enemy, node)

func poisonStackEnemyPriority(ammount : int) -> void:
	var enemy : Enemy = GLOBAL.enemies[MIDBATTLE.highestPriorityEnemyID]
	enemy.poisonStack += ammount

func getPriorityEnemy() -> Enemy:
	return GLOBAL.enemies[MIDBATTLE.highestPriorityEnemyID]

func nodeDead(charEnemy, node) -> void:
	node.modulate = Color(1.0,1.0,1.0,0.2)
	charEnemy.dead = true
	MIDBATTLE.getPriority()
	MIDBATTLE.checkLose()
	MIDBATTLE.checkWin()

func animateDamage(node,damage) -> void:
	node.get_node("Sprite/AnimationPlayer").stop()
	node.get_node("Sprite/AnimationPlayer").play("Hit")
	node.get_node("HitSprite").texture = currentAbilityTimeout.hitSprite
	node.get_node("HitSprite/AnimationPlayer").play("Hit")
	node.get_node("DamageLabel/Label").text = str(damage)
	node.get_node("DamageLabel/AnimationPlayer").stop()
	node.get_node("DamageLabel/AnimationPlayer").play("Show")

func exitAttacking() -> void:
	if currentCharEnemyTimeout is Enemy:
		currentNodeTimeout.get_node("Sprite").animation = "idle"
#	currentNodeTimeout.get_node("Sprite").texture = currentCharEnemyTimeout.spriteIdle
	currentNodeTimeout.get_node("Sprite").position.x = NODE_BACK_POSITION
	
	get_node("Timer").stop()
	MIDBATTLE.set_process(true)
	
	currentNodeTimeout = null
	currentCharEnemyTimeout = null
	currentAbilityTimeout = null
	
	GLOBAL.camera.zoom = Vector2(1.0,1.0)
	GLOBAL.background.get_node("HitFilter").visible = false

func uiUpdateHealth() -> void:
	for i in range(GLOBAL.enemySlotCount):
		if GLOBAL.enemies[i] != null:
			var enemy = GLOBAL.group_enemies.get_child(i)
			enemy.get_node("HealthBar/HealthCurrent").rect_size.x = getHealthBarSize(GLOBAL.enemies[i])
	for i in range(GLOBAL.characterSlotCount):
		if GLOBAL.characters[i] != null:
			var character = GLOBAL.group_characters.get_child(i)
			character.get_node("HealthBar/HealthCurrent").rect_size.x = getHealthBarSize(GLOBAL.characters[i])

#GUUL
func ability_posionedNail(character : Character) -> void:
	var damage = character.dexCurrent * 1
	var poison = character.dexCurrent * 0.2
	poisonStackEnemyPriority(poison)
	damageEnemyPriority(damage)

func ability_extract(_character : Character) -> void:
	var damage = getPriorityEnemy().poisonStack * 3.0
	damageEnemyPriority(damage)

func ability_miseryLovesCompany(character : Character) -> void:
	var damage = character.dexCurrent * 0.5
	var poison = 0
	if float(character.healthCurrent)/float(character.healthMax) <= 0.5:
		poison = character.dexCurrent * 1.0
	poisonStackEnemyPriority(poison)
	damageEnemyPriority(damage)

#ENEMIES
func ability_enemy_bite(enemy : Enemy) -> void:
	var damage = enemy.damage
	damageCharacterPriority(damage)
