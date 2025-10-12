extends Node2D


@onready var scene_fade_animation = $SceneTransitionAnimation/AnimationPlayer


func _ready() -> void:
	scene_fade_animation.play("fade_out")
	await scene_fade_animation.animation_finished


func _on_electrode_spawning_timer_timeout() -> void:
	pass # Replace with function body.
