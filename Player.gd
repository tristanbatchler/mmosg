extends CharacterBody3D


@export var movement_states: Dictionary

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh_root: Node3D = $MeshRoot
@onready var animation_tree: AnimationTree = $MeshRoot/AnimationTree
@onready var camera: Camera3D = $CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D

var move: MovementState
var direction: Vector3
var animation_tween: Tween

const ROTATION_SPEED: float = 8
	
func _input(event):
	if Input.is_action_just_pressed("LeftMouse"):
		var mouse_pos = get_viewport().get_mouse_position()
		
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera.project_ray_origin(mouse_pos)
		ray_query.to = ray_query.from + camera.project_ray_normal(mouse_pos) * 100.0
		
		var space = get_world_3d().direct_space_state
		var result = space.intersect_ray(ray_query)
		navigation_agent.target_position = result.position

		set_movement_state("walk")

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		set_movement_state("idle")
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	direction = next_path_position - global_position
	var target_rotation = atan2(direction.x, direction.z) - rotation.y
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, ROTATION_SPEED * delta)
	
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * move.movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func set_movement_state(state_name: String):
	move = movement_states[state_name]

	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween()
	animation_tween.tween_property(animation_tree, "parameters/movement_blend/blend_position", move.id, 0.25)
	animation_tween.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", move.animation_speed, 0.7)
