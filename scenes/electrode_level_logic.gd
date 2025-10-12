extends Node

@onready var electrode_spawner: Marker2D = $ElectrodeSpawner
@onready var electrode_destroyer: Area2D = $ElectrodeDestroyer
@onready var electrode_spawning_timer: Timer = $ElectrodeSpawningTimer

func _ready() -> void:
	electrode_spawning_timer.start()

func _process(delta: float) -> void:
	pass
