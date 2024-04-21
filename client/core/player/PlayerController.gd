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

func _input(event):
	if event.is_action_pressed("LeftMouse"):
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000.0
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var info = space.intersect_ray(query)
		
		var hit_position: Vector3 = info["position"]
		actor.navigate_to(hit_position)
		NetworkClient.send_packet({
			"Targetlocation": {
				"from_pid": GameManager.player_pid, 
				"x": hit_position.x,
				"y": hit_position.y,
				"z": hit_position.z
			}
		})

func _on_ui_chatbox_text_submitted(text: String):
	NetworkClient.send_packet({
		"Chat": {
			"from_pid": GameManager.player_pid, 
			"message": text
		}
	})
