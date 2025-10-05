extends StaticBody2D

signal tower_got_hit

func _ready() -> void:
	print("tower added to group")
	add_to_group("interactable_tower")
	
