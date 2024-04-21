extends Control

@onready var textbox: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var line_edit: LineEdit = $MarginContainer/VBoxContainer/LineEdit

signal chatbox_text_submitted(text: String)

const BLUE := "00FFFF"
const YELLOW := "FFFF00"
const WHITE := "FFFFFF"
const GREEN := "00FF00"
const BLACK := "000000"

func _ready():
	for message in GameManager.game_log:
		textbox.append_text(message)

func add_to_log(message: String, color: String = WHITE):
	message = "[color=#%s]%s[/color]\n" % [color, message]
	GameManager.game_log.append(message)
	textbox.append_text(message)

func _on_line_edit_text_submitted(new_text: String):
	if new_text != "":
		chatbox_text_submitted.emit(new_text)
		line_edit.clear()
		line_edit.release_focus()

func _input(event):
	if event.is_action_pressed("Enter"):
		if line_edit.has_focus():
			if line_edit.text == "":
				line_edit.release_focus()
		else:
			line_edit.grab_focus()

