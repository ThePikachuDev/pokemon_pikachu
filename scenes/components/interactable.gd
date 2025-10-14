extends Node2D

var is_player_in_range: bool
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	print("Interactable Component is actually running : ) ")
	pass

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("intera
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Player Entered in the area2d")
	if body.is_in_group("player"):
		is_player_in_range = true
		animation_player.play("fade_in")
	pass

func _on_area_2d_body_exited(body: Node2D) -> void:
	print("Player Exited in the area2d")
	if body.is_in_group("player"):
		is_player_in_range = false
		animation_player.play("fade_out")
