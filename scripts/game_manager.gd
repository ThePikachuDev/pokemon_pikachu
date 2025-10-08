extends Node

const MUSIC_TRACKS = [
	preload("res://assets/music/background music/1-06. Road to Viridian City – From Pallet.ogg"),
	preload("res://assets/music/background music/1-19. Theme Of Cerulean City.ogg"),
	preload("res://assets/music/background music/1-44. Hall of Fame.ogg"),
	preload("res://assets/music/background music/game-music-loop-7-145285.ogg"),
]

#@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer


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
@onready var pause_menu = $HUD/OptionsPage


@export var music_enabled: bool = true


func _load_level(new_level) -> void:
	checkpoint_position = Vector2(-999,-999)
	previous_checkpoint_node = null
	get_tree().change_scene_to_file(new_level)


func play_randome_track():
	var random_index = randi() % MUSIC_TRACKS.size()
	var random_track = MUSIC_TRACKS[random_index]
	
	if music_enabled:
		if music_player:
			music_player.stream = random_track
			music_player.play()


func _on_music_player_finished() -> void:
	play_randome_track()


func _ready():
	play_randome_track()



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
		if animated_sprite is AnimatedSprite2D:
			animated_sprite.play("damage")
			await animated_sprite.animation_finished
			
		health -= 1
		update_heart_display()
	

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
	
	if health <= 0:
		bolts = 0
		print(get_tree())
		await get_tree().call_deferred("reload_current_scene")



func play_dialogue(dialogue_resource, dialogue_start):
	if dialogues_enabled:
		var balloon: Node = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load(dialogue_resource), dialogue_start)

func update_bolt_label():
	bolt_label.text = "[img=80x80]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : " + str(bolts) + " [/font]" 


func add_bolt():
	bolts += 1
	
	if bolts >= 5:
		can_thunderbolt = true
	else:
		can_thunderbolt = false
	bolt_label.text = "[img=80x80]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : " + str(bolts) + " [/font]" 
	#if bolts == 1:
		#play_dialogue(dialogue_resource, "firstBolt")
	#elif bolts == 5:
		#can_double_jump = true
		#play_dialogue(dialogue_resource,"secondBolt")
  #
