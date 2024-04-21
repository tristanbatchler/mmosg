extends Node

const PlayerScene: PackedScene = preload("res://core/player/Player.tscn")
const ActorScene: PackedScene = preload("res://core/actor/Actor.tscn")

var player_pid: String
var others_pids: Dictionary = {}
var player_node: Node3D

var game_log: Array[String] = []

func _ready():
	NetworkClient.connect("packet_received", _on_network_client_packet_received)
	NetworkClient.connect("server_disconnected", _on_network_client_server_disconnected)
	NetworkClient.connect("server_connected", _on_network_client_server_connected)
	UI.connect("chatbox_text_submitted", _on_ui_chatbox_text_submitted)

func _on_ui_chatbox_text_submitted(text: String):
	NetworkClient.send_packet({
		"Chat": {
			"from_pid": player_pid, 
			"message": text, 
			"to_pid": NetworkClient.EVERYONE
		}
	})

func _on_network_client_packet_received(p_type: String, p_data: Dictionary):
	var from_pid: String = Marshalls.raw_to_base64(p_data["from_pid"])

	match p_type:
		"Pid":
			player_pid = from_pid

		"Hello":
			var state_view: Dictionary = p_data["state_view"]
			var x: float = state_view["x"]
			var y: float = state_view["y"]
			var z: float = state_view["z"]
			var name: String = state_view["name"]
			
			UI.add_to_log("%s has joined the server" % name)

			if from_pid == player_pid:
				player_node = PlayerScene.instantiate().init(Vector3(x, y, z), name)
				get_tree().root.add_child(player_node)

			elif not others_pids.has(from_pid):
				var actor: CharacterBody3D = ActorScene.instantiate().init(from_pid, Vector3(x, y, z), name)
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
				
		"Disconnect":
			var reason: String = p_data["reason"]
			
			if from_pid == player_pid:
				get_tree().root.remove_child(player_node)
			elif others_pids.has(from_pid):
				get_tree().root.remove_child(others_pids[from_pid])
			else:
				printerr("Got a disconnect packet from an unknown player: %s" % from_pid)

		_:
			print("Unknown packet type: ", p_type)
	
func _on_network_client_server_disconnected(code: int, reason: String, clean: bool):
	if player_node != null:
		get_tree().root.remove_child(player_node)
	UI.add_to_log("Connected to server lost", UI.YELLOW)
		
func _on_network_client_server_connected():
	UI.add_to_log("Connected to server established", UI.GREEN)
