extends Control

var dialog_image: TextureRect = null
var dialog_label: Label = null
var panel: PanelContainer = null
var is_going_brrr: bool = false
var can_run_next_dialog: bool = false
var is_next_dialog: bool = false
var current_dialog_index: int = 0

var multiDialog = ["hy there !", "i am pikachu and i am looking for ash", "he got kidnapped by team rocket !!"]
var current_dialogs: Array = []
var current_pfp: String = ""

# Example: in Main.gd or a singleton
func _input(event):
	if event.is_action_pressed("dialogue") and not panel.visible:
		start_multiple_dialogs(multiDialog, "res://assets/my aesprite assets/questionable_pikachu.png")
	
	if event is InputEventMouseButton or event.is_action_pressed("dialogue"):
		if is_going_brrr:
			# Skip current text animation
			is_going_brrr = false
		elif is_next_dialog:
			# Move to next dialog
			can_run_next_dialog = true
		else:
			# Close dialog when no more dialogs
			close_dialog()

func close_dialog():
	panel.visible = false
	current_dialog_index = 0
	current_dialogs = []
	is_next_dialog = false

func send_dialog(text, pfp_path):
	# Show panel first
	panel.visible = true
	
	# Load and set texture
	var texture: Texture2D = load(pfp_path)
	dialog_image.texture = texture
	#if texture:
		#var textureCurrentHeight = texture.get_height()
		#var textureCurrentWidth = texture.get_width()
		#
		#var max_size = Vector2(200,200) 
		#
		#var sizeX = min(max_size.x, textureCurrentWidth)
		#var sizeY = min(max_size.y, textureCurrentHeight)
		#
		#
		#dialog_image.custom_minimum_size = Vector2(sizeX, sizeY)
	#
	# Animate text
	is_going_brrr = true
	var current_text: String = ""
	
	for i in range(text.length()):
		if not is_going_brrr:
			# If skipped, show full text immediately
			dialog_label.text = text
			break
			
		var c = text[i]
		current_text += c
		
		# Handle special spacing for non-space characters
		if i < text.length() - 1 and text[i] == " " and text[i+1] == " ":
			current_text += "\u3000"  # Add ideographic space
		
		dialog_label.text = current_text
		await get_tree().create_timer(0.02).timeout
	
	is_going_brrr = false

func start_multiple_dialogs(texts: Array, pfp):
	current_dialogs = texts
	current_pfp = pfp
	current_dialog_index = 0
	process_next_dialog()

func process_next_dialog():
	if current_dialog_index >= current_dialogs.size():
		# All dialogs completed
		is_next_dialog = false
		return
	
	# Reset flags for new dialog
	can_run_next_dialog = false
	is_next_dialog = current_dialog_index < current_dialogs.size() - 1
	
	# Show current dialog
	await send_dialog(current_dialogs[current_dialog_index], current_pfp)
	
	# Wait for player to continue if there are more dialogs
	if is_next_dialog:
		while not can_run_next_dialog:
			await get_tree().create_timer(0.02).timeout
	
	# Move to next dialog
	current_dialog_index += 1
	process_next_dialog()

func _ready():
	dialog_image = $PanelContainer/MarginContainer/HBoxContainer/TextureRect
	dialog_label = $PanelContainer/MarginContainer/HBoxContainer/Label
	panel = $PanelContainer
	
	# Start with panel hidden
	panel.visible = false


#extends Control
#
#var dialog_image: TextureRect = null
#var dialog_label: Label = null
#var panel: PanelContainer = null
#var is_going_brrr: bool = false
#var can_run_next_dialog: bool = false
#var is_next_dialog: bool = false
#
#var multiDialog = ["hy there !", "i am pikachu and i am looking for ash", "he got kidnapped by team rocket !!"]
#
## Example: in Main.gd or a singleton
#func _input(event):
	#
	#if event is InputEventMouseButton:
		#if is_going_brrr:
			#is_going_brrr = false
		#elif is_next_dialog:
			#can_run_next_dialog = true
		#else:
			#close_dialog()
	##
	#if event.is_action_pressed("dialogue"):
		#send_multiple_dialogs(multiDialog, "res://assets/my aesprite assets/questionable_pikachu.png")
	#
#
#func close_dialog():
	#panel.visible = false
#
#func send_dialog(text, pfp_path):
	#var texture: Texture2D = load(pfp_path)
	#
	#var textureCurrentHeight = texture.get_height()
	#var textureCurrentWidth = texture.get_width()
	#
	#var max_size = Vector2(200,200)
	#
	#var sizeX = min(max_size.x,textureCurrentWidth)
	#var sizeY = min(max_size.y, textureCurrentHeight)
	#
	#dialog_image.texture = texture
	#dialog_image.size = Vector2(sizeX, sizeY)
	#is_going_brrr = true
	#var current_text: String = ""
	#for i in range(len(text)):
		#while current_text.ends_with("\u3000"):
			#current_text = current_text.substr(0, current_text.length() - 1)
		#var c = text[i]
		#current_text += c
		#while i < len(text)-1 and text[i] != " " and text[i+1] != " ":
			#i += 2
			#current_text += "\u3000"
		#
		#
		#dialog_label.text = current_text
		#await get_tree().create_timer(0.02).timeout
		#if not is_going_brrr:
			#dialog_label.text = text
			#break
	#is_going_brrr = false
	#
#func send_multiple_dialogs(texts: Array, pfp):
	#for i in range(len(texts)):
		#var text = texts[i]
		#if i < len(texts) - 1:
			#is_next_dialog = true
		#else:
			#is_next_dialog = false
		#await send_dialog(text, pfp)
		#while not can_run_next_dialog:
			#await get_tree().create_timer(0.02).timeout
#
#func _ready():
	#dialog_image = $PanelContainer/MarginContainer/HBoxContainer/TextureRect
	#
	#dialog_label = $PanelContainer/MarginContainer/HBoxContainer/Label
	#panel = $PanelContainer
