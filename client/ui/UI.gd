extends Control

@onready var textbox: RichTextLabel = $MarginContainer/RichTextLabel

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
