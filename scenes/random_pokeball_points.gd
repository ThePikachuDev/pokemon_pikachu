extends Node

var points_array: Array[Marker2D]
var rng = RandomNumberGenerator.new()
@onready var pokeball: Area2D = $"../pokeball"
@onready var jigglypuff_fr: Sprite2D = $"../JigglypuffFr"

func _ready() -> void:
	for point in self.get_children():
		points_array.append(point)
	print(points_array.size())
	rng.randomize()
	generate_random_ball()
	
func generate_random_ball():
	var random_number = rng.randi_range(0, points_array.size() - 1)
	var pokeball_point = points_array[random_number]
	pokeball.position = pokeball_point.position
	print(pokeball_point)

func _on_pokeball_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jigglypuff_fr.position = pokeball.position
		self.queue_free()
		
