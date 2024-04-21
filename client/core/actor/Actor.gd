extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh_root: Node3D = $MeshRoot
@onready var animation_tree: AnimationTree = $MeshRoot/AnimationTree
@onready var nameplate: Label3D = $Nameplate

var animation_tween: Tween
var rotation_speed: float = 5
var movement_speed: float = 3
var pid: String
var actor_name: String

func init(pid_: String, initial_position: Vector3, actor_name_: String):
	pid = pid_
	position = initial_position
	actor_name = actor_name_
	return self

func navigate_to(nav_position: Vector3):
	navigation_agent.target_position = nav_position
	change_animation_to("walk")

func change_animation_to(state_name: String):
	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween()

	# Animation tree blend space is set up to 0 is idle, 1 is walk, etc.
	var animation_id: int = ["idle", "walk"].find(state_name)
	animation_tween.tween_property(animation_tree, "parameters/movement_blend/blend_position", animation_id, 0.25)

func _process(delta):
	nameplate.text = actor_name

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		change_animation_to("idle")
		return
		
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var direction: Vector3 = next_path_position - global_position
	var target_rotation: float = atan2(direction.x, direction.z) - rotation.y
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)
	
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
