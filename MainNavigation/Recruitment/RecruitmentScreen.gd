extends Control

var recruit : Recruit
var characterID = null

onready var questSlotObj = preload("res://MainNavigation/Recruitment/QuestItem.tscn")

func _ready():
	recruit = Controller.transferRecruit
	characterID = recruit.character.id
	get_node("BG/CharacterSprite").texture = recruit.character.spriteIdle
	get_node("BG/NameLabel").text = recruit.character.nameShown
	
	checkStage()

func checkStage():
	var questIndex = Controller.questCompletion[characterID]
	match questIndex:
		0:
			showQuest(recruit.start)
			get_node("NextButton").visible = true
		1:
			showQuest(recruit.quest1,true)
		2:
			showQuest(recruit.quest2,true)
		3:
			showQuest(recruit.quest3,true)
		4:
			showQuest(recruit.quest4,true)
		5:
			showQuest(recruit.quest5,true)
		100:
			showQuest(recruit.end)
			get_node("RecruitButton").visible = true
		-1:
			showQuest(recruit.greeting)

func showQuest(text : String, showItems : bool = false):
	get_node("Text").bbcode_text = text
	get_node("Text/AnimationPlayer").stop()
	get_node("Text/AnimationPlayer").play("Fade")
	if showItems:
		var questIndex = Controller.questCompletion[characterID]
		var items = recruit.get("questItems" + str(questIndex))
		var ammounts = recruit.get("questAmmount" + str(questIndex))
		var gottenAmmount = 0
		for i in range(len(items)):
			var questSlot = questSlotObj.instance()
			questSlot.get_node("Name").text = items[i].nameShown
			questSlot.get_node("Ammount").text = str(Controller.getItemAmmount(items[i])) + "/" + str(ammounts[i])
			questSlot.get_node("Icon").texture = items[i].icon
			get_node("Items/Container").add_child(questSlot)
			if Controller.checkItem(items[i],ammounts[i]):
				gottenAmmount += 1
		if gottenAmmount == len(items):
			get_node("TurnInButton").visible = true

func backButton():
	var _err = get_tree().change_scene("res://MainNavigation/Worldmap/WorldMap.tscn")

func nextButton():
	Controller.questCompletion[characterID] += 1
	get_node("NextButton").visible = false
	checkStage()

func turnIn():
	var questIndex = Controller.questCompletion[characterID]
	var items = recruit.get("questItems" + str(questIndex))
	var ammounts = recruit.get("questAmmount" + str(questIndex))
	for i in range(len(items)):
		Controller.removeItem(items[i],ammounts[i])
	for questSlot in get_node("Items/Container").get_children():
		questSlot.queue_free()
	get_node("TurnInButton").visible = false
	Controller.questCompletion[characterID] += 1
	if Controller.questCompletion[characterID] > recruit.lastQuestIndex:
		Controller.questCompletion[characterID] = 100
	checkStage()

func recruitButton():
	Controller.questCompletion[characterID] = -1
	get_node("GotScreen").visible = true
	get_node("GotScreen/Sprite").texture = recruit.character.spriteIdle
	get_node("GotScreen/Name").text = recruit.character.nameShown + " RECRUITED"
	Controller.addCharacter(recruit.character)

func continueToChooseScreen():
	var _err = get_tree().change_scene("res://MainNavigation/CharacterChooseScreen/CharacterChooseScreen.tscn")
