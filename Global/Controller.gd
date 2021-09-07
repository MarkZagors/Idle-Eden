extends Node

const ITEM_TYPE_COMMON = 0
const ITEM_TYPE_EQUIPPABLE = 1

var characters = []
var inventory = []

var transferCharacter : Character = null
var transferEncounter : Encounter = null

signal inventory_changed
signal inventory_restructure_add
signal inventory_restructure_remove

func _ready():
	var placeholder = load("res://Database/Characters/placeholder.tres")
	characters.append(placeholder)
	var item : Item = load("res://Database/Items/placeholder.tres")
	addItem(item)

func addItem(item : Item) -> void:
	var found : bool = false
	for i in range(len(inventory)):
		if inventory[i].id == item.id:
			inventory[i].ammount += 1
			found = true
			break
	if not found:
		item.ammount = 1
		inventory.append(item)
		emit_signal("inventory_restructure_add")
	emit_signal("inventory_changed")

func removeItemIndex(index : int, ammount : int) -> void:
	inventory[index].ammount -= ammount
	if inventory[index].ammount < 1:
		inventory.remove(index)
		emit_signal("inventory_restructure_remove")
	emit_signal("inventory_changed")
