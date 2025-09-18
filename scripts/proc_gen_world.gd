extends Node2D


const WIDTH = 180
const HEIGHT = 160
const CELL_SIZE = 8

var grid = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	initialize_grid()
	generate_cave()
	draw_cave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(randf() < 0.45)
			

func generate_cave():
	for i in range(4):
		var new_grid = grid.duplicate(true)
		for x in range(WIDTH):
			for y in range(HEIGHT):
				var wall_count = count_neighboring_walls(x,y)
				if grid[x][y]:
					new_grid[x][y] = wall_count > 3
				else :
					new_grid[x][y] = wall_count > 4
				
		grid = new_grid


func count_neighboring_walls(x, y):
	# Count the number of walls in the 8 neighboring cells
	var count = 0
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue  # Skip the center cell
			var nx = x + i
			var ny = y + j
			# Check if the neighboring cell is out of bounds
			if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT:
				count += 1  # Count out-of-bounds as walls
			elif grid[nx][ny]:
				count += 1  # Count walls
	return count

func draw_cave():
	# Visualize the cave using ColorRect nodes
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var cell = ColorRect.new()
			cell.size = Vector2(CELL_SIZE, CELL_SIZE)
			cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			cell.color = Color.BLACK if grid[x][y] else Color.WHITE
			add_child(cell)  # Add the cell to the scene tree
