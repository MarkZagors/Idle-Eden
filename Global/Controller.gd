extends Node

const ITEM_TYPE_COMMON = 0
const ITEM_TYPE_EQUIPPABLE = 1

const ITEM_MULTIPLIER = 1

var characters = []
var inventory = []
var activeLocks = []

var charactersAvailableIDs : Array = []
var charactersBusyIDs : Array = []

var transferCharacter : Character = null
var transferEncounter : Encounter = null
var transferRecruit : Recruit = null

var currentRegion : String = "WorldMap"

var questCompletion = {
	"grunk" : 0,
	"guul" : 0,
	"lauu" : 0,
}

signal inventory_changed
signal inventory_restructure_add
signal inventory_restructure_remove
signal lock_complete_signal(drops)

func _ready():
	randomize()
	addItem(load("res://Database/Items/Resources/ElarDesert/silverOre.tres"),1000)
	addItem(load("res://Database/Items/Resources/ElarDesert/emeraldOre.tres"),1000)
	pass

func _process(delta):
	#lock Tick
	for lock in activeLocks:
		lock.timeCurrent += delta
		if lock.timeCurrent > lock.timeFull:
			#Lock complete
			lock.timeCurrent = 0.0
			for characterID in lock.characterIDs:
				findCharacter(characterID).getXp(lock.encounter.xpGive)
			var showDrops = []
			for drop in lock.encounter.drops:
				if randf() < drop.chance:
					drop.tempAmmount = drop.ammount + randi() % (drop.extraDrop+1)
					addItem(drop.item,drop.tempAmmount)
					showDrops.append(drop)
			emit_signal("lock_complete_signal",showDrops)

func addItem(item : Item, ammount : int) -> void:
	var found : bool = false
	for i in range(len(inventory)):
		if inventory[i].id == item.id:
			inventory[i].ammount += ammount * ITEM_MULTIPLIER
			found = true
			break
	if not found:
		item.ammount = ammount * ITEM_MULTIPLIER
		inventory.append(item)
		emit_signal("inventory_restructure_add")
	emit_signal("inventory_changed")

func removeItemIndex(index : int, ammount : int) -> void:
	inventory[index].ammount -= ammount
	if inventory[index].ammount < 1:
		inventory.remove(index)
		emit_signal("inventory_restructure_remove")
	emit_signal("inventory_changed")

func removeItem(item : Item, ammount : int) -> void:
	for index in range(len(inventory)):
		if index >= len(inventory):
			print("BUGGY INTERACTION IN CONTROLLER REMOVE ITEM SCRIPT!!!!, index: ", index)
			return
		if inventory[index].id == item.id:
			inventory[index].ammount -= ammount
			if inventory[index].ammount < 1:
				inventory.remove(index)

func checkItem(item : Item, ammount : int) -> bool:
	for i in range(len(inventory)):
		if inventory[i].id == item.id and inventory[i].ammount >= ammount:
			return true
	return false

func getItemAmmount(item : Item) -> int:
	for i in range(len(inventory)):
		if inventory[i].id == item.id:
			return inventory[i].ammount
	return 0

func startLock(time : float, encounter : Encounter, characterIds) -> void:
	var lock = Lock.new()
	lock.timeFull = time
	lock.timeCurrent = 0.0
	lock.encounter = encounter
	lock.characterIDs = characterIds
	activeLocks.append(lock)
	pass

func endLock(lock : Lock) -> void:
	for lockActive in activeLocks:
		if lock == lockActive:
			for characterID in lockActive.characterIDs:
				charactersAvailableIDs.append(characterID)
				charactersBusyIDs.erase(characterID)
			activeLocks.erase(lockActive)
			break

func changeScene(region: String):
	if region == "current":
		region = currentRegion
	if region == "WorldMap":
		var _err = get_tree().change_scene("res://MainNavigation/Worldmap/WorldMap.tscn")
	else:
		var _err = get_tree().change_scene("res://Regions/" + region + ".tscn")

func findCharacter(lookingID : String) -> Character:
	for ch in characters:
		if ch.id == lookingID:
			return ch
	return null

func setupActiveCharacters() -> void:
	for character in characters:
		charactersAvailableIDs.append(character.id)

func addStartingCharacter() -> void:
	var guul : Character = load("res://Database/Characters/guul.tres")
	addCharacter(guul)

func addCharacter(character : Character) -> void:
	characters.append(character)
	charactersAvailableIDs.append(character.id)
