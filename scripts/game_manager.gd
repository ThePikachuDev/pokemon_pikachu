extends Node

var bolts = 0
var can_double_jump: bool

var hearts_list : Array[TextureRect]
var health = 3

var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
var dialogue_start = "start"

const Balloon = preload("res://dialogue/balloon.tscn")

func load_hearts():
	var hearts_parent = $HUD/HBoxContainer
	for heart in hearts_parent.get_children():
		hearts_list.append(heart)
	print(hearts_list)
	

func take_damage():
	if health > 0:
		health -= 1
		#i'll play auido over here
		update_heart_display()
	

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
	
	if health <= 0:
		get_tree().reload_current_scene()


func _ready():
	pass

func play_dialogue(dialogue_resource, dialogue_start):
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load(dialogue_resource), dialogue_start)

func add_bolt():
	var bolt_label: RichTextLabel = $HUD/RichTextLabel
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
  
