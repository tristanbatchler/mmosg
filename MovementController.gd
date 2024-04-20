extends Node
class_name MovementController

signal movement_state_changed(state_name: String)

@export var rotation_speed: float = 8
@export var movement_speed: float = 8
@export var player: CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = player.get_node("NavigationAgent3D")
@onready var mesh_root: Node3D = player.get_node("MeshRoot")

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		movement_state_changed.emit("idle")
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var direction: Vector3 = next_path_position - player.global_position
	var target_rotation: float = atan2(direction.x, direction.z) - player.rotation.y
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)
	
	var new_velocity: Vector3 = player.global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	player.velocity = safe_velocity
	player.move_and_slide()


func _on_floor_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event.is_action_pressed("LeftMouse"):
		navigation_agent.target_position = position
		movement_state_changed.emit("walk")
		
