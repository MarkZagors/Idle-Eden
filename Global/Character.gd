extends Resource
class_name Character

#ID AND NAME
export var id : String = "NULL"
export var nameShown : String = "NULL"

#ABILITIES INVENTORY
var abilitySlotCount = 6
export(Array,Resource) var abilities = [null,null,null,null,null,null]
var inventorySlotCount = 4
export(Array,Resource) var abilityAll = [null]
export(Array,Resource) var inventory = [null,null,null,null]

#REWARDS
export(Array,Resource) var rewards

#STATS
export var healthBase : int = 10
export var strBase : int = 0
export var dexBase : int = 0
export var intBase : int = 0
export var armorBase : float = 1.0
export var magicDefenceBase : float = 1.0
export var speed : float = 1.0

#LEVEL
export var level : int = 1
export var xpCurrent : int = 0
export var xpNext : int = 5
var xpAll : PoolIntArray = [0,5,15,35,60,100,9999]

#SPRITES
export var spriteFace : Texture = null
export var spriteIdle : Texture = null

#SPRITE CONTROLS
export var spriteScale : float = 1
export var spriteFlip : bool = false
export var spriteOffset : Vector2 = Vector2.ZERO
export var hpbarOffset : Vector2 = Vector2.ZERO

#BG CONTROLS
export var screenBGCol : Color = Color.black
export var screenFORECol : Color = Color.black

#HIDDEN VARIABLES
var cooldownAbilityCurrent = 0.0
var cooldownAbilityTotal = 1.0
var abilityID = 0
var priority : int = 0
var dead : bool = false
var position : int = -1
var effects = []
var statBuffs = [] #{"stat": STAT.DEX, "ammount": 10, "time": 3.0}

#HIDDEN STATS
var healthMax : int = 10
var healthCurrent : int = 10
var strCurrent : int = 0
var dexCurrent: int = 0
var intCurrent : int = 0
var armorCurrent : float = 1.0
var magicDefenceCurrent : float = 1.0

func getXp(ammount : int) -> void:
	xpCurrent += ammount
	while xpCurrent >= xpAll[level]:
		level += 1
		for reward in rewards:
			if reward.level == level:
				if reward.isAbility:
					abilityAll.append(reward.ability)
