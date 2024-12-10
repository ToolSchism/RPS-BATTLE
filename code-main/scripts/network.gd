extends Node
const DEFAULT_PORT = 28960
const MAX_PLAYERS = 2

var peer: ENetMultiplayerPeer = null
var is_server = false
var player_name = "name"
var opponent_name = "otherName"
var upnp_mapper: UPNP = null
var upnp_device = null

var network_thread: Thread = null
var mutex: Mutex = null

signal connected
signal failedToConnect
signal rageQuit
signal gameReady
signal networkProgress(message, percent)

func _ready() -> void:
	peer = ENetMultiplayerPeer.new()
	upnp_mapper = UPNP.new()
	mutex = Mutex.new()
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _thread_safe_progress(message: String, percent: float) -> void:
	call_deferred("emit_signal", "networkProgress", message, percent)

func create_game(ip: String = "") -> void:
	if network_thread and network_thread.is_started():
		network_thread.wait_to_finish()
	
	network_thread = Thread.new()
	network_thread.start(func(): _threaded_network_setup(true, ip))

func join_game(ip: String) -> void:
	if network_thread and network_thread.is_started():
		network_thread.wait_to_finish()
	
	network_thread = Thread.new()
	network_thread.start(func(): _threaded_network_setup(false, ip))

func _threaded_network_setup(is_hosting: bool, ip: String = "") -> void:
	_thread_safe_progress("Generating player name...", 10.0)
	player_name = generate_player_name()
	
	if is_hosting:
		_thread_safe_progress("Setting up UPnP...", 30.0)
		_setup_upnp()

	_thread_safe_progress("Preparing network...", 50.0)
	call_deferred("_setup_network_connection", is_hosting, ip)


func _setup_network_connection(is_hosting: bool, ip: String = "") -> int:
	var error = FAILED

	if is_hosting:
		error = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
		if error == OK:
			multiplayer.multiplayer_peer = peer
			is_server = true
			_thread_safe_progress("Server created", 99.0)
			await get_tree().create_timer(2).timeout
			_thread_safe_progress("Have a friend join to start!", 100.0)
	else:
		error = peer.create_client(ip, DEFAULT_PORT)
		if error == OK:
			multiplayer.multiplayer_peer = peer
			is_server = false
			_thread_safe_progress("Connecting to server...", 50.0)
			await get_tree().create_timer(4).timeout
			var status = peer.get_connection_status()
			if status == 1:
				_thread_safe_progress("Connection timed out.", 0.0)
				await get_tree().create_timer(1).timeout
				peer.close()
	
	if error != OK:
		call_deferred("_handle_network_error", error)
	
	return error

func _handle_network_error(error) -> void:
	print("Network setup error: ", error)
	multiplayer.multiplayer_peer = null
	failedToConnect.emit()

func _setup_upnp() -> void:
	var result = upnp_mapper.discover(5000)
	if result == OK:
		var device = upnp_mapper.get_gateway()
		if device:
			var port_map_result = device.add_port_mapping(
				DEFAULT_PORT, 
				DEFAULT_PORT, 
				"Godot Multiplayer Game", 
				"UDP"
			)
			if port_map_result != OK:
				print("Port mapping failed")
		else:
			print("No UPnP gateway found")
	else:
		print("UPnP discovery failed")

func _on_player_connected(id) -> void:
	print("Player connected: " + str(id))
	connected.emit()
	if is_server:
		rpc("receive_player_name", player_name)

func _on_player_disconnected(id):
	print("Player disconnected: " + str(id))
	rageQuit.emit()

func _on_connected_to_server():
	print("Connected to server")
	rpc("receive_player_name", player_name)

func _on_connection_failed():
	print("Failed to connect")
	multiplayer.multiplayer_peer = null
	failedToConnect.emit()

func _on_server_disconnected():
	print("Disconnected from server")
	rageQuit.emit()
	_teardown_upnp()

@rpc("any_peer", "reliable")
func receive_player_name(name):
	if opponent_name != name:
		opponent_name = name
		print("Opponent name received: " + opponent_name)
		gameReady.emit()

func _teardown_upnp() -> void:
	if upnp_device:
		var success = upnp_device.delete_port_mapping(DEFAULT_PORT, "UDP")
		if success == OK:
			print("Port mapping removed")
		else:
			print("Failed to remove port mapping")

func generate_player_name() -> String:
	var prefixes = ["cool", "pro", "epic", "super", "awesome"]
	var mainWord = ["sheep", "cow", "wolf", "lion", "dog", "cat", "gator"]
	var id = str(randi_range(1, 1500))
	return prefixes[randi_range(0, prefixes.size() - 1)] + " " + mainWord[randi_range(0, mainWord.size() - 1)] + id
