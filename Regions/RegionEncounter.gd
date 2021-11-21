extends TextureButton

const TICK_SPEED = 0.5
var tickCurr = 0.0

export var encounter : Resource = null
var screen_encounter : ColorRect = null
var mainNode : Control = null
var locked : bool = false
var lock : Lock = null

func _ready():
	screen_encounter = get_node("../UIMap/EncounterScreen")
	mainNode = get_node("..")
	get_node("IconContainer/TextureRect").texture = encounter.icon
	var _err = Controller.connect("lock_complete_signal",self,"lockComplete")
	var _err2 = connect("pressed",self,"openEncounter")
	#check lock
	for lockInController in Controller.activeLocks:
		if lockInController.encounter == encounter:
			self.lock = lockInController
			locked = true
			get_node("LockProgress").visible = true
			get_node("LockProgress").max_value = lock.timeFull

func _process(delta):
	tickCurr += delta
	if tickCurr > TICK_SPEED:
		if locked:
			get_node("LockProgress").value = lock.timeCurrent
		tickCurr = 0.0

func lockComplete(drops) -> void:
	if locked:
		var text : String = ""
		for drop in drops:
			text += str(drop.item.nameShown) + " (%d)\n"%drop.ammount
		text.erase(text.length()-1,1)
		get_node("DropLabel").text = text
		get_node("DropLabel/AnimationPlayer").stop()
		get_node("DropLabel/AnimationPlayer").play("Drop")
		get_node("LockProgress").value = lock.timeCurrent

func openEncounter() -> void:
	screen_encounter.visible = true
	screen_encounter.get_node("StartButton").visible = false
	screen_encounter.get_node("EndButton").visible = false
	screen_encounter.get_node("NameLabel").text = encounter.nameShown
	if locked:
		screen_encounter.get_node("EndButton").visible = true
	else:
		screen_encounter.get_node("StartButton").visible = true
	mainNode.encounterSelected = encounter
	mainNode.lockSelected = lock
	mainNode.nodeSelected = self

func endLock() -> void:
	locked = false
	get_node("LockProgress").visible = false
	lock = null

