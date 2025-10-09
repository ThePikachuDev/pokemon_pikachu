extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var bolts_label: RichTextLabel = $CanvasLayer/ShopContainer/BoltsLabel

@onready var game_manager = %GameManager
@onready var speed_timer: Timer = $CanvasLayer/ShopContainer/SpeedItemCard/SpeedTimer
@onready var jump_timer: Timer = $CanvasLayer/ShopContainer/JumpItemCard/JumpTimer

var is_speed_enabled: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		canvas_layer.visible = !canvas_layer.visible
	#bolts_label.text = "[img=38x48]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : " + str(game_manager.bolts) + " [/font]"
	
	if is_speed_enabled:
		game_manager.speed *= 2
		speed_timer.start()
	



func _on_black_background_mouse_entered() -> void:
	canvas_layer.visible = false


func _on_speed_button_pressed() -> void:
	if GameManager.bolts >= 5:
		GameManager.bolts -= 5
		is_speed_enabled = true
	

func _on_speed_timer_timeout() -> void:
	game_manager.player_speed /= 2
