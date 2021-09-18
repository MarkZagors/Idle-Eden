extends Node
onready var GLOBAL = get_parent()

export var Path_table_winScreen: NodePath
onready var table_winScreen : ColorRect = get_node(Path_table_winScreen)
export var Path_table_loseScreen: NodePath
onready var table_loseScreen : ColorRect = get_node(Path_table_loseScreen)

func win():
	table_winScreen.visible = true
	
	for ch in GLOBAL.characters:
		if ch != null:
			ch.getXp(GLOBAL.encounter.xpGive)

func lose():
	table_loseScreen.visible = true
