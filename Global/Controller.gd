extends Node

const ITEM_TYPE_COMMON = 0
const ITEM_TYPE_EQUIPPABLE = 1

var characters = []
var inventory = []
var activeLocks = []

var charactersAvailableIDs : Array = []
var charactersBusyIDs : Array = []

var transferCharacter : Character = null
var transferEncounter : Encounter = null

signal inventory_changed
signal inventory_restructure_add
signal inventory_restructure_remove
signal lock_complete_signal(drops)

func _ready():
	var placeholder = load("res://Database/Characters/placeholder.tres")
	characters.append(placeholder)
	charactersAvailableIDs.append(placeholder.id)
	var item : Item = load("res://Database/Items/placeholder.tres")
	addItem(item,2)

func _process(delta):
	lockTick(delta)

func lockTick(delta : float) -> void:
	for lock in activeLocks:
		lock.timeCurrent += delta
		if lock.timeCurrent > lock.timeFull:
			lockComplete(lock)

func lockComplete(lock : Lock) -> void:
	lock.timeCurrent = 0.0
	for characterID in lock.characterIDs:
		findCharacter(characterID).getXp(lock.encounter.xpGive)
	var showDrops = []
	for drop in lock.encounter.drops:
		if randf() < drop.chance:
			addItem(drop.item,drop.ammount)
			showDrops.append(drop)
	emit_signal("lock_complete_signal",showDrops)
	

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

func startLock(time : float, encounter : Encounter, characterIds) -> void:
	var lock = Lock.new()
	lock.timeFull = time
	lock.timeCurrent = 0.0
	lock.encounter = encounter
	lock.characterIDs = characterIds
	activeLocks.append(lock)
	pass
