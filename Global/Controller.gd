extends Node

const ITEM_TYPE_COMMON = 0
const ITEM_TYPE_EQUIPPABLE = 1

var characters = []
var inventory = []

var charactersAvailableIDs : Array = []
var charactersBusyIDs : Array = []

var transferCharacter : Character = null
var transferEncounter : Encounter = null

signal inventory_changed
signal inventory_restructure_add
signal inventory_restructure_remove

func _ready():
	var placeholder = load("res://Database/Characters/placeholder.tres")
	characters.append(placeholder)
	charactersAvailableIDs.append(placeholder.id)
	var item : Item = load("res://Database/Items/placeholder.tres")
	addItem(item,2)

func addItem(item : Item, ammount : int) -> void:
	var found : bool = false
	for i in range(len(inventory)):
		if inventory[i].id == item.id:
			inventory[i].ammount += ammount
			found = true
			break
	if not found:
		item.ammount = ammount
		inventory.append(item)
		emit_signal("inventory_restructure_add")
	emit_signal("inventory_changed")

func removeItemIndex(index : int, ammount : int) -> void:
	inventory[index].ammount -= ammount
	if inventory[index].ammount < 1:
		inventory.remove(index)
		emit_signal("inventory_restructure_remove")
	emit_signal("inventory_changed")

func findCharacter(lookingID : String) -> Character:
	for ch in characters:
		if ch.id == lookingID:
			return ch
	return null
