extends Node
onready var GLOBAL = get_node("../..")
onready var MIDBATTLE = get_parent()

const HEALTH_TEMP_DECREASE = 50
const NODE_BACK_POSITION = 70

enum TYPE {
	PHYSICAL,
	MAGIC
}

enum STAT {
	DEX,
	STR,
	INT,
	ARMOR,
	MAGICDEF
}

enum EFFECTS {
	ENCHANT_CHORD,
}

var currentNodeTimeout : TextureButton = null
var currentCharEnemyTimeout = null
var currentAbilityTimeout : Ability = null

onready var damageSplashSprite = preload("res://SPRITES/Particles/BloodSplaterPixel.png")
onready var magicDamageSplashSprite = preload("res://SPRITES/Particles/MagicSplatter.png")
onready var healSplashSprite = preload("res://SPRITES/Particles/HealSplash.png")

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
	
	currentNodeTimeout = node
	currentCharEnemyTimeout = charEnemy
	GLOBAL.camera.zoom = Vector2(1,1)
	GLOBAL.background.get_node("HitFilter").visible = true
	if charEnemy is Character:
		node.get_node("Sprite").position.x += 50
	else:
		node.get_node("Sprite").position.x -= 50
	
	var ability : Ability = charEnemy.abilities[charEnemy.abilityID]
	currentAbilityTimeout = ability
	match ability.id:
		"poisonedNail":
			ability_posionedNail(charEnemy)
		"extract":
			ability_extract(charEnemy)
		"miseryLovesCompany":
			ability_miseryLovesCompany(charEnemy)
		"peacefulMelody":
			ability_peacefulMelody(charEnemy)
		"powerChord":
			ability_powerChord(charEnemy)
		"attack":
			ability_enemy_attack(charEnemy)
		_:
			push_error("NO ABILITY ID FOUND: " + str(ability.id))
	
	uiUpdateHealth()
	charEnemy.abilityID = (charEnemy.abilityID + 1) % len(charEnemy.abilities)
	
	get_node("Timer").wait_time = 0.25
	get_node("Timer").start()

func getHealthBarSize(charEnemy) -> int:
	var ratio : float = float(charEnemy.healthCurrent) / float(charEnemy.healthMax)
	ratio = clamp(ratio,0.0,1.0)
	return int(ratio * 150)

#DAMAGE/HEALING

func damageEnemyPriority(damage : int, type) -> void:
	var enemy : Enemy = GLOBAL.enemies[MIDBATTLE.highestPriorityEnemyID]
	if type == TYPE.PHYSICAL:
		damage /= enemy.armor
	elif type == TYPE.MAGIC:
		damage /= enemy.magicDefence
	enemy.healthCurrent -= damage
	
	var node = GLOBAL.group_enemies.get_child(MIDBATTLE.highestPriorityEnemyID)
	animateDamage(node,damage,type)
	if enemy.healthCurrent < 1:
		nodeDead(enemy, node)
	
func damageCharacterPriority(damage : int, type) -> void:
	var character : Character = GLOBAL.characters[MIDBATTLE.highestPriorityCharacterID]
	if type == TYPE.PHYSICAL:
		damage /= character.armorCurrent
	elif type == TYPE.MAGIC:
		damage /= character.magicDefenceCurrent
	character.healthCurrent -= damage
	
	var node = GLOBAL.group_characters.get_child(MIDBATTLE.highestPriorityCharacterID)
	animateDamage(node,damage,type)
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

func updateEffectTimer() -> void:
	for i in range(len(GLOBAL.characters)):
		if GLOBAL.characters[i] == null:
			continue
		var character : Character = GLOBAL.characters[i]
		
		var remove = []
		for buff in character.statBuffs:
			buff.time -= 0.5
			if buff.time <= 0.1:
				remove.append(buff)
		for removeBuff in remove:
			match removeBuff.stat:
				STAT.DEX:
					character.dexCurrent -= removeBuff.ammount
				STAT.STR:
					character.strCurrent -= removeBuff.ammount
				STAT.INT:
					character.intCurrent -= removeBuff.ammount
				STAT.ARMOR:
					character.armorCurrent -= removeBuff.ammount
				STAT.MAGICDEF:
					character.magicDefenceCurrent -= removeBuff.ammount
			character.statBuffs.erase(removeBuff)
		print(character.statBuffs)

func poisonStackEnemyPriority(ammount : int) -> void:
	var enemy : Enemy = GLOBAL.enemies[MIDBATTLE.highestPriorityEnemyID]
	ammount /= enemy.armor
	enemy.poisonStack += ammount

func healLowestHp(ammount : int) -> void:
	var lowest = 2.0
	var lowChar : Character = null
	for character in GLOBAL.characters:
		if character != null and character.dead != true:
			var hp = float(character.healthCurrent)/float(character.healthMax)
			if hp < lowest:
				lowest = hp
				lowChar = character
	lowChar.healthCurrent += ammount
	lowChar.healthCurrent = clamp(lowChar.healthCurrent,0,lowChar.healthMax)
	var node = GLOBAL.group_characters.get_child(lowChar.position)
	animateHeal(node,ammount)

func healAll(ammount : int) -> void:
	for i in range(len(GLOBAL.characters)):
		var character : Character = GLOBAL.characters[i]
		if character != null and character.dead != true:
			character.healthCurrent += ammount
			character.healthCurrent = clamp(character.healthCurrent,0,character.healthMax)
			var node = GLOBAL.group_characters.get_child(i)
			animateHeal(node,ammount)

func damageAll(damage : int, type) -> void:
	for i in range(len(GLOBAL.enemies)):
		var enemy : Enemy = GLOBAL.enemies[i]
		if enemy != null and enemy.dead != true:
			if type == TYPE.PHYSICAL:
				damage /= enemy.armor
			elif type == TYPE.MAGIC:
				damage /= enemy.magicDefence
			enemy.healthCurrent -= damage
			
			var node = GLOBAL.group_enemies.get_child(i)
			animateDamage(node,damage,type)
			if enemy.healthCurrent < 1:
				nodeDead(enemy, node)

#DAMAGE/HEALING end ////

func getPriorityEnemy() -> Enemy:
	return GLOBAL.enemies[MIDBATTLE.highestPriorityEnemyID]

func getNonDeadCharacters() -> Array:
	var characters = []
	for i in range(len(GLOBAL.characters)):
		var character : Character = GLOBAL.characters[i]
		if character != null and character.dead != true:
			characters.append(character)
	return characters

func getNonDeadCharactersAndNodes() -> Array:
	var characters = []
	var nodes = []
	for i in range(len(GLOBAL.characters)):
		var character : Character = GLOBAL.characters[i]
		if character != null and character.dead != true:
			characters.append(character)
			var node = GLOBAL.group_characters.get_child(i)
			nodes.append(node)
	return [characters, nodes]

func nodeDead(charEnemy, node) -> void:
	node.modulate = Color(1.0,1.0,1.0,0.2)
	charEnemy.dead = true
	MIDBATTLE.getPriority()
	MIDBATTLE.checkLose()
	MIDBATTLE.checkWin()

func animateDamage(node,damage,type) -> void:
	if type == TYPE.PHYSICAL:
		node.get_node("DamageLabel").texture = damageSplashSprite
	elif type == TYPE.MAGIC:
		node.get_node("DamageLabel").texture = magicDamageSplashSprite
	node.get_node("Sprite/AnimationPlayer").stop()
	node.get_node("Sprite/AnimationPlayer").play("Hit")
	node.get_node("HitSprite").texture = currentAbilityTimeout.hitSprite
	node.get_node("HitSprite/AnimationPlayer").play("Hit")
	node.get_node("DamageLabel/Label").text = str(damage)
	node.get_node("DamageLabel/AnimationPlayer").stop()
	node.get_node("DamageLabel/AnimationPlayer").play("Show")

func animateHeal(node,heal) -> void:
	node.get_node("DamageLabel").texture = healSplashSprite
	node.get_node("DamageLabel/Label").text = str(heal)
	node.get_node("DamageLabel/AnimationPlayer").stop()
	node.get_node("DamageLabel/AnimationPlayer").play("Show")

func exitAttacking() -> void:
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

func checkEffect(charEnemy,effect) -> bool:
	for e in charEnemy.effects:
		if e == effect:
			return true
	return false

#GUUL
func ability_posionedNail(character : Character) -> void:
	var damage = character.dexCurrent * 1
	var poison = character.dexCurrent * 0.2
	poisonStackEnemyPriority(poison)
	damageEnemyPriority(damage, TYPE.PHYSICAL)

func ability_extract(_character : Character) -> void:
	var damage = getPriorityEnemy().poisonStack * 3.0
	damageEnemyPriority(damage, TYPE.PHYSICAL)

func ability_miseryLovesCompany(character : Character) -> void:
	var damage = character.dexCurrent * 0.5
	var poison = 0
	if float(character.healthCurrent)/float(character.healthMax) <= 0.5:
		poison = character.dexCurrent * 1.0
	poisonStackEnemyPriority(poison)
	damageEnemyPriority(damage, TYPE.PHYSICAL)

func ability_poisionOverflow(character : Character) -> void:
	var damage = character.dexCurrent * 1.0
	var poison = 0
	var enemy : Enemy = getPriorityEnemy()
	if enemy.poisonStack >= 200:
		poison == 200
	
	poisonStackEnemyPriority(poison)
	damageEnemyPriority(damage, TYPE.PHYSICAL)

#LAUU
func ability_peacefulMelody(character : Character) -> void:
	var heal = 10
	healAll(heal)
	
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		character.effects.remove(EFFECTS.ENCHANT_CHORD)
	character.effects.append(EFFECTS.ENCHANT_CHORD)

func ability_powerChord(character : Character) -> void:
	var damage = character.intCurrent * 1.5
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		damage *= 2
	damageEnemyPriority(damage, TYPE.MAGIC)
	
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		character.effects.remove(EFFECTS.ENCHANT_CHORD)

func ability_energeticMelody(character : Character) -> void:
	var buff = 15
	for character in getNonDeadCharacters():
		character.dexCurrent += buff
		character.statBuffs.append({"stat": STAT.DEX, "ammount": buff, "time": 3.0})
	
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		character.effects.remove(EFFECTS.ENCHANT_CHORD)
	character.effects.append(EFFECTS.ENCHANT_CHORD)

func ability_sunsetSong(character : Character) -> void:
	var damage = character.intCurrent * 1.0
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		damage *= 2.0
	damageAll(damage, TYPE.MAGIC)
	
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		character.effects.remove(EFFECTS.ENCHANT_CHORD)

func ability_repeatedChord(character : Character) -> void:
	var damage = character.intCurrent * 2
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		damage *= 2
	damageEnemyPriority(damage, TYPE.MAGIC)
	
	if character.effects.has(EFFECTS.ENCHANT_CHORD):
		character.effects.remove(EFFECTS.ENCHANT_CHORD)
	character.effects.append(EFFECTS.ENCHANT_CHORD)

#GRUNK
func ability_smash(character : Character) -> void:
	var damage = character.strCurrent * 1
	damageEnemyPriority(damage, TYPE.PHYSICAL)

func ability_taunt(character : Character) -> void:
	character.priority += 10

func ability_bodySlam(character : Character) -> void:
	var damage = character.armorCurrent * 5.0
	damageEnemyPriority(damage, TYPE.PHYSICAL)

func ability_fortify(character : Character) -> void:
	var buff = 2.0
	character.armorCurrent += buff
	character.statBuffs.append({"stat": STAT.ARMOR, "ammount": buff, "time": 3.0})

#ENEMIES
func ability_enemy_attack(enemy : Enemy) -> void:
	var damage = enemy.damage
	damageCharacterPriority(damage, TYPE.PHYSICAL)
