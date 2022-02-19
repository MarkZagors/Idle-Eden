class_name Recruit
extends Resource

export var characterName : String
export var characterId : String
export var icon : Texture
export var characterSprite : Texture
export(String,MULTILINE) var start = ""
export(String,MULTILINE) var end = ""

export(String,MULTILINE) var quest1 = ""
export(String,MULTILINE) var quest2 = ""
export(String,MULTILINE) var quest3 = ""
export(String,MULTILINE) var quest4 = ""
export(String,MULTILINE) var quest5 = ""

export(String,MULTILINE) var greeting = ""

export(Array, Resource) var questItems1 = [null]
export(Array, int) var questAmmount1 = [null]
export(Array, Resource) var questItems2 = [null]
export(Array, int) var questAmmount2 = [null]
export(Array, Resource) var questItems3 = [null]
export(Array, int) var questAmmount3 = [null]
export(Array, Resource) var questItems4 = [null]
export(Array, int) var questAmmount4 = [null]
export(Array, Resource) var questItems5 = [null]
export(Array, int) var questAmmount5 = [null]

export var reward1 = [null]
export var reward2 = [null]
export var reward3 = [null]
export var reward4 = [null]
export var reward5 = [null]
