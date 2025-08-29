extends Control

@onready var dialog_image: TextureRect =$PanelContainer/MarginContainer/HBoxContainer/TextureRect
@onready var dialog_label: Label = $PanelContainer/MarginContainer/HBoxContainer/Label
@onready var panel: PanelContainer = $PanelContainer

var is_animating_text: bool = false
var can_advance_dialog: bool = false
var has_next_dialog: bool = false
var current_dialog_index: int = 0
var current_dialogs: Array = []
var current_pfp: String = ""

var default_dialogs = [
	"Detective Pikachu reporting, i'll guide you through some basics",
	"you can move with WASD or arrow keys ",
	"press space/upArrow/w once to jump and twice to double jump",
]

signal dialogue_started()
signal dialogue_ended()

func _input(event):
	if event.is_action_pressed("dialogue") and not panel.visible:
		start_multiple_dialogs(default_dialogs, "res://assets/my aesprite assets/pikachu pfp.png")
		dialogue_started.emit()
	
	if event is InputEventMouseButton or event.is_action_pressed("dialogue"):
		if is_animating_text:
			is_animating_text = false
		elif has_next_dialog:
			can_advance_dialog = true
		else:
			close_dialog()

func close_dialog():
	panel.visible = false
	current_dialog_index = 0
	current_dialogs = []
	has_next_dialog = false
	dialogue_ended.emit()

func show_dialog(text: String, pfp_path: String) -> void:
	panel.visible = true
	
	var texture: Texture2D = load(pfp_path)
	if texture:
		dialog_image.texture = texture
	
	is_animating_text = true
	var displayed_text: String = ""
	
	for i in range(text.length()):
		if not is_animating_text:
			dialog_label.text = text
			break
			
		var character = text[i]
		displayed_text += character
		
		if i < text.length() - 1 and text[i] == " " and text[i+1] == " ":
			displayed_text += "\u3000"
		
		dialog_label.text = displayed_text
		await get_tree().create_timer(0.02).timeout
	
	is_animating_text = false

func start_multiple_dialogs(texts: Array, pfp: String) -> void:
	current_dialogs = texts
	current_pfp = pfp
	current_dialog_index = 0
	await process_next_dialog()

func process_next_dialog() -> void:
	if current_dialog_index >= current_dialogs.size():
		has_next_dialog = false
		return
	
	can_advance_dialog = false
	has_next_dialog = current_dialog_index < current_dialogs.size() - 1
	
	await show_dialog(current_dialogs[current_dialog_index], current_pfp)
	
	if has_next_dialog:
		while not can_advance_dialog:
			await get_tree().create_timer(0.02).timeout
	
	current_dialog_index += 1
	await process_next_dialog()

func _ready():
	panel.visible = false
