extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var scene_transition_animation = $SceneTransitionAnimation/AnimationPlayer

@export var texture: Texture2D = null
@export var can_teleport: bool = false
func  _ready() -> void:
	if texture:
		sprite_2d.texture = texture


func _on_body_entered(body: Node2D) -> void:
	if can_teleport:
		if body.is_in_group("player"):
			scene_transition_animation.play("fade_in")
			await scene_transition_animation.animation_finished
			get_tree().change_scene_to_file("res://scenes/level_1.tscn")
