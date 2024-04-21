extends Node3D

@onready var actor: CharacterBody3D = $Actor
@onready var navigation_agent: NavigationAgent3D = $Actor/NavigationAgent3D
@onready var floor_body: StaticBody3D = get_tree().get_first_node_in_group("FloorBody")

var actor_initial_position: Vector3

func _ready():
	actor.init(GameManager.player_pid, actor_initial_position)
	floor_body.connect("input_event", _on_floor_input_event)

func init(initial_position: Vector3):
	actor_initial_position = initial_position
	return self

func _on_floor_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event.is_action_pressed("LeftMouse"):
		actor.navigate_to(position)
		
		NetworkClient.send_packet({
			"Targetlocation": {
				"from_pid": GameManager.player_pid, 
				"x": position.x,
				"y": position.y,
				"z": position.z
			}
		})
