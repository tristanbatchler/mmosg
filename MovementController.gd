extends Node
class_name MovementController

signal movement_state_changed(state_name: String)

@export var camera: Camera3D
@export var rotation_speed: float = 8
@export var movement_speed: float = 8
@export var player: CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = player.get_node("NavigationAgent3D")
@onready var mesh_root: Node3D = player.get_node("MeshRoot")

func _input(event):
	if Input.is_action_just_pressed("LeftMouse"):
		var mouse_pos = get_viewport().get_mouse_position()
		
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera.project_ray_origin(mouse_pos)
		ray_query.to = ray_query.from + camera.project_ray_normal(mouse_pos) * 100.0
		
		var space = player.get_world_3d().direct_space_state
		var result = space.intersect_ray(ray_query)
		navigation_agent.target_position = result.position

		movement_state_changed.emit("walk")

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
