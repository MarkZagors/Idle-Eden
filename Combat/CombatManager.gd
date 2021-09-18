extends Node

export var Path_group_characters: NodePath
var group_characters : Node2D
export var Path_group_enemies: NodePath
var group_enemies : Node2D

var characters : Array = [null,null,null]
var characterSlotCount = 3
var enemies : Array = [null,null,null]
var enemySlotCount = 3
var encounter : Encounter = null

enum {
	STARTING,
	FIGHTING,
	ATTACKING,
	END
}
var state : int = STARTING

func _init():
	encounter = Controller.transferEncounter

func _enter_tree():
	group_enemies = get_node(Path_group_enemies)
	group_characters = get_node(Path_group_characters)

func exit():
	var _err = get_tree().change_scene("res://MainNavigation/WorldMap.tscn")
	for ch in characters:
		if ch != null:
			Controller.charactersAvailableIDs.append(ch.id)
			Controller.charactersBusyIDs.erase(ch.id)
	pass
