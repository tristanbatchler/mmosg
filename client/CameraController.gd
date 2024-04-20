extends Node3D

@onready var cam_yaw: Node3D = $CamYaw
@onready var cam_pitch: Node3D = $CamYaw/CamPitch
@onready var spring_arm: SpringArm3D = $CamYaw/CamPitch/SpringArm3D

var yaw: float
var pitch: float

var yaw_sensitivity: float = 0.5
var pitch_sensitivity: float = 0.5
var zoom_sensitivity: float = 1.0

var max_pitch: float = 75

func _ready():
	yaw = cam_yaw.rotation_degrees.y
	pitch = cam_pitch.rotation_degrees.x


func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("MiddleMouse"):
		yaw -= event.relative.x * yaw_sensitivity
		pitch -= event.relative.y * pitch_sensitivity
		pitch = clamp(pitch, -max_pitch, max_pitch)

	if Input.is_action_pressed("MouseWheelUp") and spring_arm.spring_length > zoom_sensitivity:
		spring_arm.spring_length -= zoom_sensitivity
	elif Input.is_action_pressed("MouseWheelDown"):
		spring_arm.spring_length += zoom_sensitivity
		


func _physics_process(delta):
	cam_yaw.rotation_degrees.y = yaw
	cam_pitch.rotation_degrees.x = pitch
