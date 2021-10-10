extends Resource
class_name Enemy

#ID
export var id : String = "NULL"

#SPRITES
export var spriteIdle : Texture = null
export var spriteAttacking : Texture = null

#STATS
export var healthMax : int = 10
export var damage : int = 10
export var speed : float = 1.0

#ABILITIES
var abilitySlotCount = 2
export(Array,Resource) var abilities = [null,null]

#HIDDEN VARIABLES
var cooldownAbilityCurrent = 0.0
var cooldownAbilityTotal = 1.0
var abilityID = 0
var priority : int = 0
var dead : bool = false

#HIDDEN STATS
var healthCurrent : int = 10
var strCurrent : int = 0
var dexCurrent: int = 0
var intCurrent : int = 0

#COUNTERS
var poisonStack : int = 0
