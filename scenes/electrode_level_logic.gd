extends Node

const electrode_scene = preload("res://scenes/components/rolling_ball_enemy.tscn")

@onready var electrode_spawner: Marker2D = $ElectrodeSpawner
@onready var electrode_destroyer: Area2D = $ElectrodeDestroyer
@onready var electrode_spawning_timer: Timer = $ElectrodeSpawningTimer
# Remove these three unused references since you are spawning dynamically:
# @onready var rolling_ball_enemy: CharacterBody2D = $Electrodes/RollingBallEnemy 
# @onready var rolling_ball_enemy_2: CharacterBody2D = $Electrodes/RollingBallEnemy2
# @onready var rolling_ball_enemy_3: CharacterBody2D = $Electrodes/RollingBallEnemy3 
@onready var electrodes_parent: Node2D = $Electrodes


func _ready() -> void:
	# 1. Manual Spawn Check (Keep this to confirm the fix)
	var electrode_test = electrode_scene.instantiate()
	
	# 2. Position the electrode relative to its parent
	# Use the Spawner's GLOBAL position, then convert it to the PARENT's local position.
	electrode_test.position = electrode_spawner.global_position - electrodes_parent.global_position
	
	electrodes_parent.add_child(electrode_test)
	print("✅ TEST: Manually spawned an electrode (should be visible now)!")
	
	# Start the repeating spawn
	electrode_spawning_timer.start()


func _on_electrode_spawning_timer_timeout() -> void:
	var electrode = electrode_scene.instantiate()
	
	# CRITICAL FIX: Calculate the new position relative to the 'Electrodes' parent node.
	# The electrode's 'position' must be the Spawner's GLOBAL position minus the Parent's GLOBAL position.
	electrode.position = electrode_spawner.global_position - electrodes_parent.global_position
	
	# Add the new electrode to the designated parent node.
	electrodes_parent.add_child(electrode)
	print("⭐ Electrode added at local position: ", electrode.position)


func _on_electrode_destroyer_body_entered(body: Node2D) -> void:
	if body.is_in_group("electrode"):
		body.queue_free()
		print("💥 Electrode destroyed")
