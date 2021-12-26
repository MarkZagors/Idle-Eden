extends Control

export var Path_group_recipes : NodePath
onready var group_recipes : VBoxContainer = get_node(Path_group_recipes)
export var Path_button_base : NodePath
onready var button_base : TextureButton = get_node(Path_button_base)
export var Path_group_augments : NodePath
onready var group_augments : Control = get_node(Path_group_augments)
export var Path_button_craft : NodePath
onready var button_craft : Control = get_node(Path_button_craft)
export var Path_type_select : NodePath
onready var type_select : Label = get_node(Path_type_select)

onready var recipeButton = preload("res://MainNavigation/CraftingScreen/CraftingSlot.tscn")

onready var recipes = [
	preload("res://Database/Recipes/test.tres"),
	preload("res://Database/Recipes/test_augment.tres"),
	preload("res://Database/Recipes/test_augment2.tres"),
]

var base: Recipe = null
var augments = [null,null,null,null]
var full: bool = false

func _ready():
	render("base", "addBase")

func _exit_tree():
	removeRecipe(false, 0)
	removeRecipe(true, 0)
	removeRecipe(true, 1)
	removeRecipe(true, 2)
	removeRecipe(true, 3)

func render(type: String, funcName: String) -> void:
	if type == "base":
		type_select.text = "Select a base"
	else:
		type_select.text = "Select an augment"
	
	for _recipe in recipes:
		var recipe: Recipe = _recipe
		if recipe.type == type:
			var rButton = recipeButton.instance()
			rButton.get_node("Icon").texture = recipe.icon
			rButton.get_node("NameLabel").text = recipe.name
			rButton.connect("pressed",self,funcName,[recipe])
#			Add text
			var text : String = ""
			if recipe.strength != 0:
				text += str(recipe.strength) + " STR "
			if recipe.dexterity != 0:
				text += str(recipe.dexterity) + " DEX "
			if recipe.intelligence != 0:
				text += str(recipe.intelligence) + " INT "
			if recipe.effect == true:
				text += " +EFFECT "
			rButton.get_node("StatsLabel").text = text
			for i in range(len(recipe.ingredients)):
				var ingredient = rButton.get_node("Recipe").get_child(i)
				ingredient.visible = true
				ingredient.get_node("Icon").texture = recipe.ingredients[i].icon
				ingredient.get_node("Ammount").text = str(recipe.ingredientsAmmount[i]) + "x"
			group_recipes.add_child(rButton)

func addBase(recipe: Recipe) -> void: #add base
	if not checkAndRemove(recipe):
		return
	
	base = recipe
	button_base.get_node("Sprite").texture = base.icon
	clearButtons()
	render("augment", "addAugment")
	setFull()

func addAugment(recipe: Recipe) -> void: #add augment
	if not checkAndRemove(recipe):
		return
	
	for index in range(len(augments)):
		if augments[index] == null:
			augments[index] = recipe
			group_augments.get_child(index).get_node("Sprite").texture = recipe.icon
			break
	
	setFull()

func setFull() -> void:
	var nullCount = 0
	for index in range(len(augments)):
		if augments[index] == null:
			nullCount += 1
			break
	if nullCount == 0:
		full = true
		button_craft.visible = true
	else:
		full = false
		button_craft.visible = false

func clearButtons() -> void:
	for button in group_recipes.get_children():
		button.queue_free()

func checkAndRemove(recipe: Recipe) -> bool:
	if full:
		return false
	
	for index in range(len(recipe.ingredients)):
		if not Controller.checkItem(recipe.ingredients[index],recipe.ingredientsAmmount[index]):
			return false
	for index in range(len(recipe.ingredients)):
		Controller.removeItem(recipe.ingredients[index],recipe.ingredientsAmmount[index])
	return true

func removeRecipe(isAugment: bool, augmentIndex: int) -> void:
	if not isAugment:
		if base == null:
			return
		for i in range(len(base.ingredients)):
			Controller.addItem(base.ingredients[i], base.ingredientsAmmount[i])
		base = null
		button_base.get_node("Sprite").texture = null
		clearButtons()
		render("base", "addBase")
	else:
		var augment = augments[augmentIndex]
		if augment == null:
			return
		for i in range(len(augment.ingredients)):
			Controller.addItem(augment.ingredients[i], augment.ingredientsAmmount[i])
		augments[augmentIndex] = null
		group_augments.get_child(augmentIndex).get_node("Sprite").texture = null
	full = false
	button_craft.visible = false

func craftItem() -> void:
	var item : Item = base.result.duplicate()
	var id : String = item.id
	augments.sort_custom(RecipeSorter, "sort_ascending")
	for augment in augments:
		id += "_" + str(augment.name)
		item.strBase += augment.strength
		item.dexBase += augment.dexterity
		item.intBase += augment.intelligence
	item.id = id
	
	Controller.addItem(item,1)
	
	base = null
	button_base.get_node("Sprite").texture = null
	for i in range(len(augments)):
		augments[i] = null
		group_augments.get_child(i).get_node("Sprite").texture = null
	clearButtons()
	render("base", "addBase")
	full = false
	button_craft.visible = false

class RecipeSorter:
	static func sort_ascending(a, b):
		if a.name < b.name:
			return true
		return false

