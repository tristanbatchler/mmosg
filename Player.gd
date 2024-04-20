extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh_root: Node3D = $MeshRoot
@onready var animation_tree: AnimationTree = $MeshRoot/AnimationTree

var animation_tween: Tween

func _on_movement_controller_movement_state_changed(state_name: String):
	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween()

	# Animation tree blend space is set up to 0 is idle, 1 is walk, etc.
	var animation_id: int = ["idle", "walk"].find(state_name)
	animation_tween.tween_property(animation_tree, "parameters/movement_blend/blend_position", animation_id, 0.25)
