extends Node3D

@onready var actor: CharacterBody3D = $Actor
@onready var navigation_agent: NavigationAgent3D = $Actor/NavigationAgent3D
@onready var camera: Camera3D = $Actor/CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D

var actor_initial_data: InitialActorData

func init(initial_data: InitialActorData):
	actor_initial_data = initial_data
	return self

func _ready():
	actor.init(GameManager.player_pid, actor_initial_data)
	UI.connect("chatbox_text_submitted", _on_ui_chatbox_text_submitted)

func _physics_process(delta):
	if Input.is_action_just_pressed("LeftMouse"):
		var clicked_position: Vector3 = mouse_to_world_position()

		actor.navigate_to(clicked_position)
		NetworkClient.send_packet({
			"Targetlocation": {
				"from_pid": GameManager.player_pid, 
				"x": clicked_position.x,
				"y": clicked_position.y,
				"z": clicked_position.z
			}
		})

func _on_ui_chatbox_text_submitted(text: String):
	NetworkClient.send_packet({
		"Chat": {
			"from_pid": GameManager.player_pid, 
			"message": text
		}
	})

func mouse_to_world_position() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var info: Dictionary = space_state.intersect_ray(query)
	return info["position"]
