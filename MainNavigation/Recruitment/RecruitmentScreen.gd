extends Control

var recruit : Recruit

onready var questSlotObj = preload("res://MainNavigation/Recruitment/QuestItem.tscn")

func _ready():
	recruit = Controller.transferRecruit
	get_node("BG/CharacterSprite").texture = recruit.characterSprite
	get_node("BG/NameLabel").text = recruit.characterName
	
	checkStage()

func checkStage():
	var questIndex = Controller.questCompletion[recruit.characterId]
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
		-1:
			showQuest(recruit.greeting)

func showQuest(text : String, showItems : bool = false):
	get_node("Text").bbcode_text = text
	get_node("Text/AnimationPlayer").stop()
	get_node("Text/AnimationPlayer").play("Fade")
	if showItems:
		var questIndex = Controller.questCompletion[recruit.characterId]
		var items = recruit.get("questItems" + str(questIndex))
		var ammounts = recruit.get("questAmmount" + str(questIndex))
		for i in range(len(items)):
			var questSlot = questSlotObj.instance()
			questSlot.get_node("Name").text = items[i].nameShown
			questSlot.get_node("Ammount").text = str(ammounts[i])
			questSlot.get_node("Icon").texture = items[i].icon
			get_node("Items/Container").add_child(questSlot)

func backButton():
	var _err = get_tree().change_scene("res://MainNavigation/Worldmap/WorldMap.tscn")

func nextButton():
	Controller.questCompletion[recruit.characterId] += 1
	get_node("NextButton").visible = false
	checkStage()
