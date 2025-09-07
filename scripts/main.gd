extends Node2D


#const lines: Array[String] = [
	#"less goo !",
	#"i made it !!",
	#"I am sooo much happy !",
	#"you dont bileve me that i dont know how to speel that 3rd word in this line"
#]


func _input(event: InputEvent) -> void:
	pass	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#MyDialougueManager.send_dialog(lines,"res://assets/my aesprite assets/pikachu pfp.png" )
	#MyDialougueManager.dialouge_running.emit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_kill_zone_below_world_body_entered(body: Node2D) -> void:
	get_tree().call_deferred("reload_current_scene")
	
