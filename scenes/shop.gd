extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var bolts_label: RichTextLabel = $CanvasLayer/ShopContainer/BoltsLabel

@onready var game_manager = %GameManager

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		canvas_layer.visible = !canvas_layer.visible
	
	bolts_label.text = "[img=38x48]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : " + str(game_manager.bolts) + " [/font]"

func _on_black_background_mouse_entered() -> void:
	canvas_layer.visible = false
