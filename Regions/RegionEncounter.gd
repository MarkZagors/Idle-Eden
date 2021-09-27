extends TextureButton

const TICK_SPEED = 0.5
var tickCurr = 0.0

export var encounter : Resource = null
var locked : bool = false
var lock : Lock = null

func _ready():
	get_node("IconContainer/TextureRect").texture = encounter.icon
	var _err = Controller.connect("lock_complete_signal",self,"lockComplete")
	checkLock()

func _process(delta):
	tickCurr += delta
	if tickCurr > TICK_SPEED:
		tick()
		tickCurr = 0.0

func tick():
	if locked:
		updateLocked()

func checkLock() -> void:
	for lockInController in Controller.activeLocks:
		if lockInController.encounter == encounter:
			self.lock = lockInController
			locked = true
			get_node("LockProgress").visible = true
			get_node("LockProgress").max_value = lock.timeFull

func lockComplete(drops) -> void:
	if locked:
		var text : String = ""
		for drop in drops:
			text += str(drop.item.nameShown) + " (%d)\n"%drop.ammount
		text.erase(text.length()-1,1)
		get_node("DropLabel").text = text
		get_node("DropLabel/AnimationPlayer").stop()
		get_node("DropLabel/AnimationPlayer").play("Drop")
		updateLocked()

func updateLocked() -> void:
	get_node("LockProgress").value = lock.timeCurrent

func gotoEncounter() -> void:
	if locked:
		return
	Controller.transferEncounter = encounter
	var _err = get_tree().change_scene("res://Combat/Combat.tscn")
