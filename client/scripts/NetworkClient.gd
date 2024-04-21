extends Node

const Msgpack = preload("res://scripts/Msgpack.gd")
static var EVERYONE: String = "AAAAAAAAAAAAAAAAAAAAAA=="

var socket := WebSocketPeer.new() 

signal server_connected()
signal server_disconnected(code: int, reason: String, clean: bool)
signal packet_received(p_type: String, p_data: Dictionary)

@export var hostname: String = "localhost"
@export var port: int = 8081

func _ready() -> void:
	var tls_options: TLSOptions = TLSOptions.client()
	var err: int = socket.connect_to_url("wss://%s:%d" % [hostname, port], tls_options)
	if err:
		printerr("Unable to connect, error code %d" % err)
		set_process(false)
	else:
		server_connected.emit()

func _process(delta) -> void:
	socket.poll()
	
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet: Dictionary = Msgpack.decode(socket.get_packet())["result"]
			var p_type: String = packet.keys()[0]
			var p_data: Dictionary = packet[p_type]
			packet_received.emit(p_type, p_data)
			print("Received packet %s" % packet)
	
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
		
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		server_disconnected.emit(code, reason, code != -1)
		printerr("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false)

func send_packet(packet: Dictionary) -> int:
	var data: PackedByteArray = Msgpack.encode(packet)["result"]
	var err: int = socket.send(data)
	if err:
		printerr("Error sending data. Error code: ", err)
		return not OK
	else:
		return OK
		
func _exit_tree():
	socket.close()
