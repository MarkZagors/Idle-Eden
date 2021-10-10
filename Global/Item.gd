extends Resource
class_name Item

#INFO
export var id : String = "NULL"
export var nameShown : String = "NULL"
export(String,MULTILINE) var description = ""

#SPRITES
export var icon : Texture = null

#EXTRA
enum TYPES { COMMON, EQUIPPABLE }
export(TYPES) var type : int = 0

#STATS
export var healthBase : int = 0
export var strBase : int = 0
export var dexBase : int = 0
export var intBase : int = 0

#HIDDEN
var ammount : int = 0

func fullDescription() -> String:
	var text = description
	if healthBase > 0:
		text += "\nHealth: +" + str(healthBase)
	if strBase > 0:
		text += "\nStrength: +" + str(strBase)
	if dexBase > 0:
		text += "\nDextirity: +" + str(dexBase)
	if intBase > 0:
		text += "\nIntelligence: +" + str(intBase)
	return text
