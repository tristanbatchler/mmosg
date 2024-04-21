extends Node

const PlayerScene: PackedScene = preload("res://Player.tscn")
const ActorScene: PackedScene = preload("res://Actor.tscn")

var player_pid: String
var others_pids: Dictionary = {}

func _ready():
	NetworkClient.connect("packet_received", _on_network_client_packet_received)

func _on_network_client_packet_received(p_type: String, p_data: Dictionary):
	var from_pid: String = Marshalls.raw_to_base64(p_data["from_pid"])

	match p_type:
		"Pid":
			player_pid = from_pid
			print("Player PID: ", player_pid)


		"Hello":
			var state_view: Dictionary = p_data["state_view"]
			var x: float = state_view["x"]
			var y: float = state_view["y"]
			var z: float = state_view["z"]

			if from_pid == player_pid:
				var player: Node3D = PlayerScene.instantiate().init(Vector3(x, y, z))
				get_tree().root.add_child(player)

			elif not others_pids.has(from_pid):
				var actor: CharacterBody3D = ActorScene.instantiate().init(from_pid, Vector3(x, y, z))
				others_pids[from_pid] = actor
				get_tree().root.add_child(actor)

			else:
				printerr("Already know %s but got another HelloPacket from it" % from_pid)
			

		"Targetlocation":
			var x: float = p_data["x"]
			var y: float = p_data["y"]
			var z: float = p_data["z"]

			if others_pids.has(from_pid):
				others_pids[from_pid].navigate_to(Vector3(x, y, z))

		_:
			print("Unknown packet type: ", p_type)
	
