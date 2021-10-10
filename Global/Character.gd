extends Resource
class_name Character

#ID AND NAME
export var id : String = "NULL"
export var nameShown : String = "NULL"

#SPRITES
export var spriteFace : Texture = null
export var spriteIdle : Texture = null
export var spriteAttacking : Texture = null

#ABILITIES INVENTORY
var abilitySlotCount = 6
export(Array,Resource) var abilities = [null,null,null,null,null,null]
var inventorySlotCount = 4
export(Array,Resource) var abilityAll = [null]
export(Array,Resource) var inventory = [null,null,null,null]

#STATS
export var healthBase : int = 10
export var strBase : int = 0
export var dexBase : int = 0
export var intBase : int = 0
export var speed : float = 0

#LEVEL
var level : int = 1
var xpCurrent : int = 0
var xpNext : int = 5
var xpAll : PoolIntArray = [0,5,15,35,60,100,9999]

#HIDDEN VARIABLES
var cooldownAbilityCurrent = 0.0
var cooldownAbilityTotal = 1.0
var abilityID = 0
var priority : int = 0
var dead : bool = false

#HIDDEN STATS
var healthMax : int = 10
var healthCurrent : int = 10
var strCurrent : int = 0
var dexCurrent: int = 0
var intCurrent : int = 0

func getXp(ammount : int) -> void:
	xpCurrent += ammount
	while xpCurrent >= xpAll[level]:
		level += 1
