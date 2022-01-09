extends Resource
class_name Recipe

export var name: String = "NULL"
export var icon: Texture
export var result: Resource = null
export(String, "base", "augment") var type : String = "base"
export(Array, Resource) var ingredients: Array
export var ingredientsAmmount: PoolIntArray
export var health: int
export var strength: int
export var dexterity: int
export var intelligence: int
export var effect: bool
