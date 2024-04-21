extends Node3D

@onready var actor: CharacterBody3D = $Actor
@onready var navigation_agent: NavigationAgent3D = $Actor/NavigationAgent3D
@onready var floor_body: StaticBody3D = get_tree().get_first_node_in_group("FloorBody")

var actor_initial_pos: Vector3
var actor_name: String

func init(initial_position: Vector3, name_: String):
	actor_initial_pos = initial_position
	actor_name = name_
	return self

func _ready():
	actor.init(GameManager.player_pid, actor_initial_pos, actor_name)
	floor_body.connect("input_event", _on_floor_input_event)
	UI.connect("chatbox_text_submitted", _on_ui_chatbox_text_submitted)

func _on_floor_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event.is_action_pressed("LeftMouse"):
		actor.navigate_to(event_position)
		
		NetworkClient.send_packet({
			"Targetlocation": {
				"from_pid": GameManager.player_pid, 
				"x": event_position.x,
				"y": event_position.y,
				"z": event_position.z
			}
		})

func _on_ui_chatbox_text_submitted(text: String):
	NetworkClient.send_packet({
		"Chat": {
			"from_pid": GameManager.player_pid, 
			"message": text
		}
	})
