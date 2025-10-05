extends Node2D

var is_player_in_range: bool
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var npc_sprite: Sprite2D = $NpcSprite

@export var i_wanna_use_my_custom_sprite: bool 
@export var texture: Texture 
@export var timeline: DialogicTimeline 
@export var f_addons: bool = false

func _ready() -> void:
	if i_wanna_use_my_custom_sprite:
		npc_sprite.visible = false
	
	
	if texture:
		npc_sprite.texture = texture

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if is_player_in_range:
			
			Dialogic.start(timeline)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = true
		animation_player.play("fade_in")
	pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = false
		animation_player.play("fade_out")
