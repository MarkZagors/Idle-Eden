extends Node2D

export var SPEED_HEX_BIG : float = 0.0
export var SPEED_HEX_2 : float = 0.0
export var SPEED_HEX_3 : float = 0.0

export var colorHex : Color;
export var colorBG : Color;

func _ready():
	get_node("../BGColor").material.set_shader_param("color",colorBG)
	get_node("Hex1").material.set_shader_param("color",colorHex)
	get_node("Hex2").material.set_shader_param("color",colorHex)
	get_node("Hex3").material.set_shader_param("color",colorHex)

func _process(delta):
	get_node("Hex1").rotation += delta * SPEED_HEX_BIG
	get_node("Hex2").rotation += delta * SPEED_HEX_2
	get_node("Hex3").rotation += delta * SPEED_HEX_3
