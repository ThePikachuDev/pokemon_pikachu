extends Node

var bolts = 0
var can_double_jump: bool

var hearts_list : Array[TextureRect]
var health = 3
var is_shader_enabled: bool = false

var can_thunderbolt: bool = false

var checkpoint_position: Vector2 = Vector2(-999,-999)
var previous_checkpoint_node: Sprite2D = null
var active_checkpoint: Sprite2D

@export var dialogues_enabled: bool = true
var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
var dialogue_start = "start"

const Balloon = preload("res://dialogue/balloon.tscn")

@onready var player_hurt_animtion: AnimationPlayer = $"../Player/HurtAnimation"
@onready var player_hurt_timer: Timer = $"../Player/HurtTimer"

@onready var bolt_label: RichTextLabel = $HUD/RichTextLabel

#func _load_level(new_level) -> void:
	#checkpoint_position = Vector2(-999,-999)
	#previous_checkpoint_node = null
	#get_tree().change_scene_to_file(new_level)

func load_hearts():
	var hearts_parent = $HUD/HBoxContainer
	for heart in hearts_parent.get_children():
		hearts_list.append(heart)
	

func take_damage():
	if health > 0:
		print(health)
		var heart_parent = hearts_list[health -1]
		var animated_sprite = heart_parent.get_child(0)
		
		player_hurt_animtion.play("hurt_animation")
		player_hurt_timer.start()
		await player_hurt_timer.timeout
		player_hurt_animtion.play("RESET")
		# Check if the child is a valid AnimatedSprite2D and then play the animation
		if animated_sprite is AnimatedSprite2D:
			animated_sprite.play("damage")
			# You may want to await the animation's finish signal, not the play function itself
			await animated_sprite.animation_finished
			
		health -= 1
		
		#i'll play auido over here
		update_heart_display()
	

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
	
	if health <= 0:
		print(get_tree())
		await get_tree().call_deferred("reload_current_scene")


func _ready():
	pass

func play_dialogue(dialogue_resource, dialogue_start):
	if dialogues_enabled:
		var balloon: Node = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load(dialogue_resource), dialogue_start)

func update_bolt_label():
	bolt_label.text = "[img=128x128]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=64]bolts : " + str(bolts) + " [/font]" 


func add_bolt():
	bolts += 1
	if bolts >= 5:
		can_thunderbolt = true
	bolt_label.text = "[img=80x80]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : " + str(bolts) + " [/font]" 
	#if bolts == 1:
		#play_dialogue(dialogue_resource, "firstBolt")
	#elif bolts == 5:
		#can_double_jump = true
		#play_dialogue(dialogue_resource,"secondBolt")
  #
