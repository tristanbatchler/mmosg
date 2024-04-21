extends Node

const PlayerScene: PackedScene = preload("res://core/player/Player.tscn")
const ActorScene: PackedScene = preload("res://core/actor/Actor.tscn")

const Meshes: Array[PackedScene] = [
	preload("res://assets/animated_character_scenes/Eve.tscn"), 
	preload("res://assets/animated_character_scenes/TheBoss.tscn"),
	preload("res://assets/animated_character_scenes/Prisoner.tscn"),
	preload("res://assets/animated_character_scenes/Parasite.tscn"),
	preload("res://assets/animated_character_scenes/Guard.tscn"),
	preload("res://assets/animated_character_scenes/SportyGranny.tscn"),
]

var player_pid: String
var player: Node3D
var other_actors: Dictionary = {}

var game_log: Array[String] = []

func _ready():
	NetworkClient.connect("packet_received", _on_network_client_packet_received)
	NetworkClient.connect("server_disconnected", _on_network_client_server_disconnected)
	NetworkClient.connect("server_connected", _on_network_client_server_connected)

func _on_network_client_packet_received(p_type: String, p_data: Dictionary):
	var from_pid: String = Marshalls.raw_to_base64(p_data["from_pid"])

	match p_type:
		"Pid":
			player_pid = from_pid

		"Hello":
			if other_actors.has(from_pid):
				printerr("Already know %s but got another HelloPacket from it" % from_pid)
				return
			
			var state_view: Dictionary = p_data["state_view"]
			var initial_data: InitialActorData = InitialActorData.new()
			initial_data.a_position = Vector3(state_view["x"], state_view["y"], state_view["z"])
			initial_data.a_name = state_view["name"]
			initial_data.a_mesh = Meshes[state_view["mesh_index"]]

			UI.add_to_log("%s has joined the server" % initial_data.a_name)
			
			if from_pid == player_pid:
				player = PlayerScene.instantiate().init(initial_data)
				get_tree().root.add_child(player)
			else:
				var actor: CharacterBody3D = ActorScene.instantiate().init(from_pid, initial_data)
				other_actors[from_pid] = actor
				get_tree().root.add_child(actor)


		"Targetlocation":
			var x: float = p_data["x"]
			var y: float = p_data["y"]
			var z: float = p_data["z"]

			if other_actors.has(from_pid):
				other_actors[from_pid].navigate_to(Vector3(x, y, z))
				
		"Disconnect":
			var reason: String = p_data["reason"]
			
			if from_pid == player_pid:
				UI.add_to_log("You have disconnected: %s" % reason)
				get_tree().quit()
			elif other_actors.has(from_pid):
				get_tree().root.remove_child(other_actors[from_pid])
				UI.add_to_log("%s has disconnected" % other_actors[from_pid].initial_data.a_name)
			else:
				printerr("Got a disconnect packet from an unknown player: %s" % from_pid)
				
		"Chat":
			var sender_actor: CharacterBody3D
			if from_pid == player_pid:
				sender_actor = player.actor
			elif other_actors.has(from_pid):
				sender_actor = other_actors[from_pid]
			else:
				printerr("Got a chat packet from an unknown player: %s" % from_pid)
			
			var message: String = p_data["message"]
			UI.add_to_log("%s: %s" % [sender_actor.initial_data.a_name, message])
			

		_:
			print("Unknown packet type: ", p_type)
	
func _on_network_client_server_disconnected(code: int, reason: String, clean: bool):
	UI.add_to_log("Server connection closed with code: %d, reason %s. Clean: %s" % [code, reason, clean], UI.YELLOW)
		
func _on_network_client_server_connected():
	UI.add_to_log("Connected to server established", UI.GREEN)
