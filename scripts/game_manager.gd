extends Node

var bolts = 0
var can_double_jump: bool

@onready var bolt_label: RichTextLabel = $HUD/RichTextLabel
#const dialogue_ballon = preload("res://dialogue/balloon.tscn")
var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
var dialogue_start = "start"

const Balloon = preload("res://dialogue/balloon.tscn")

func _ready():
	pass

func play_dialogue(dialogue_resource, dialogue_start):
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load(dialogue_resource), dialogue_start)
	#
	#DialogueManager.show_example_dialogue_balloon(load("res://dialogue/StarterHelper.dialogue"),"start")

func add_bolt():
	bolts += 1
	bolt_label.text = "[img=80x80]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : " + str(bolts) + " [/font]" 
	if bolts == 1:
		play_dialogue(dialogue_resource, "firstBolt")
		print("bolt 1 condition ran")
	elif bolts == 5:
		can_double_jump = true
		play_dialogue(dialogue_resource,"secondBolt")
		print("2nd condition run")

	print(bolts)
  
