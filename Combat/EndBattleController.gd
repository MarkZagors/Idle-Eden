extends Node
onready var GLOBAL = get_parent()
onready var MIDBATTLE = get_parent().get_node("MidBattleController")

export var Path_table_winScreen: NodePath
onready var table_winScreen : ColorRect = get_node(Path_table_winScreen)
export var Path_table_loseScreen: NodePath
onready var table_loseScreen : ColorRect = get_node(Path_table_loseScreen)

func win():
	table_winScreen.visible = true
	table_winScreen.get_node("TimeLabel").text = "TIME: " + str(round(GLOBAL.time)) + "s"
	
	for ch in GLOBAL.characters:
		if ch != null:
			ch.getXp(GLOBAL.encounter.xpGive)
	
	for drop in GLOBAL.encounter.drops:
		if randf() < drop.chance:
			var ammount = drop.ammount + randi() % (drop.extraDrop+1)
			Controller.addItem(drop.item,ammount)
	MIDBATTLE.set_process(false)
	GLOBAL.timeEnd = GLOBAL.time

func lose():
	table_loseScreen.visible = true
