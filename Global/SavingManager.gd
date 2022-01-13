extends Node

func save_game() -> void:
	var saveFile = File.new()
	saveFile.open("user://savefile.save", File.WRITE)
	var charactersAmmount = len(Controller.characters)
	saveFile.store_var(charactersAmmount)
	var inventoryAmmount = len(Controller.inventory)
	saveFile.store_var(inventoryAmmount)
	saveFile.close()
	
	var directoryCharacters = Directory.new()
	if not directoryCharacters.dir_exists("user://characters"):
		directoryCharacters.make_dir("user://characters")
	var directoryInventory = Directory.new()
	if not directoryInventory.dir_exists("user://inventory"):
		directoryInventory.make_dir("user://inventory")
	
	for i in range(charactersAmmount):
		var _e = ResourceSaver.save("user://characters/character%s.tres" % i, Controller.characters[i])
	
	for i in range(inventoryAmmount):
		var _e = ResourceSaver.save("user://inventory/item%s.tres" % i, Controller.inventory[i])
	
	print("saved!")

func load_game() -> void:
	var saveFile = File.new()
	saveFile.open("user://savefile.save", File.READ)
	var charactersAmmount = saveFile.get_var()
	var inventoryAmmount = saveFile.get_var()
	saveFile.close()
	
	for i in range(charactersAmmount):
		Controller.characters.append(ResourceLoader.load("user://characters/character%s.tres" % i))
	for i in range(inventoryAmmount):
		Controller.inventory.append(ResourceLoader.load("user://inventory/item%s.tres" % i))
	
	Controller.setupActiveCharacters()
	
	pass
