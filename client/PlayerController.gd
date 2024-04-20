extends Node3D

@onready var actor: CharacterBody3D = $Actor
@onready var navigation_agent: NavigationAgent3D = $Actor/NavigationAgent3D

func _on_floor_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event.is_action_pressed("LeftMouse"):
		actor.navigate_to(position)
