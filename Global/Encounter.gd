extends Resource
class_name Encounter

export var id : String = "NULL"
export var icon : Texture = null

export var xpGive : int = -1

export(Array, Resource) var enemies = [null,null,null]
export(Array, Resource) var drops = []
