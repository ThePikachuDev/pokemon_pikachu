extends Node2D
@onready var color_rect: ColorRect = $ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("crouch"):
		color_rect.modulate = Color(0,0,0,1)
	if event.is_action_released("crouch"):
		color_rect.modulate = Color(1,1,1,1)
		
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()

	pass # Replace with function body.
