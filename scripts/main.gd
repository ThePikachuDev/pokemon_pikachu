extends Node2D



func _input(event: InputEvent) -> void:
	pass	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_kill_zone_below_world_body_entered(body: Node2D) -> void:
		get_tree().call_deferred("reload_current_scene")
	
