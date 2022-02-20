extends Node

export var Path_group_characters: NodePath
var group_characters : Node2D
export var Path_group_enemies: NodePath
var group_enemies : Node2D
export var Path_camera: NodePath
onready var camera : Camera2D = get_node(Path_camera)
export var Path_background: NodePath
onready var background : Sprite = get_node(Path_background)

var characters : Array = [null,null,null]
var characterSlotCount = 3
var enemies : Array = [null,null,null]
var enemySlotCount = 3
var encounter : Encounter = null

var time : float = 0.0
var timeEnd : float = 0.0

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
	Controller.changeScene("current")
	for ch in characters:
		if ch != null:
			Controller.charactersAvailableIDs.append(ch.id)
			Controller.charactersBusyIDs.erase(ch.id)
	pass

func lock() -> void:
	Controller.changeScene("current")
	var characterIds = []
	for character in characters:
		if character != null:
			characterIds.append(character.id)
	Controller.startLock(timeEnd, encounter, characterIds)
