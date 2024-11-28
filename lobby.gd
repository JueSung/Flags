extends Node
class_name Lobby

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

signal set_ID(peer_id)

var server_ip = "localhost"
var server_port = 7777
var MAX_CONNECTIONS = 8

#dictionary containing player info and player id as keys
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

var players_loaded = 0

var upnp
var upnp_device = null

func setup_upnp():
	print("Searching for UPnP devices...")
	upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		print(discover_result)
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var map_result_udp = upnp.add_port_mapping(server_port, server_port, "godot_udp", "UDP", 86400)
			var map_result_tcp = upnp.add_port_mapping(server_port, server_port, "godot_tcp", "TCP",86400)
			if map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
				print("UDP forwarded successful")
			else:
				upnp.add_port_mapping(server_port, server_port,"","UDP")
				print("UDP didn't work first time")
			if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(server_port, server_port, "", "TCP")
				print("TCP didn't work first time")
	
	
	"""var err = upnp.discover()
	if err != OK:
		print("upnp.discover failed...")
	if upnp.get_device_count() > 0:
		upnp_device = upnp.get_device(0)  # Use the first discovered device
		print("UPnP device found:", upnp_device)
		var result = upnp_device.add_port_mapping(server_port, server_port, "UDP", "Godot Game")
		if result:
			print("Port", server_port, "forwarded successfully!")
		else:
			print("Failed to forward port.")
	else:
		print("No UPnP devices found.")"""

func fetch_public_ip():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	http_request.request("https://api64.ipify.org")

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		server_ip = body.get_string_from_utf8()
		print("Public IP:", server_ip)
	else:
		print("Failed to fetch public IP.")


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_game():
	#these two are used for port forwarding when host is a player. Does not work
	#setup_upnp()
	#fetch_public_ip()
	#---------
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(server_port, MAX_CONNECTIONS)
	if result != OK:
		print("Failed to create server")
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port", server_port)
	
	players[1] = player_info
	set_ID.emit(1)
	player_connected.emit(1, player_info)

func join_game():
	#get server ip and port from lineedits
	server_ip = get_parent().get_node("HUD").get_node("IP").text
	server_port = int(get_parent().get_node("HUD").get_node("Port").text)
	#----------
	
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(server_ip, server_port)
	if result != OK:
		print("Failed to connect to server")
		get_parent().get_node("HUD").get_node("WaitingToStart").text = "Failed to connect to server\nplease return to main menu"
		return
	multiplayer.multiplayer_peer = peer
	print("Connected to server at", server_ip, ":", server_port)
		

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Main.start_game()
			players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
#when player first connects, they register themself. Then for 1 host and 2 additional joining the order is:
#1st hosts: 2 adds 1
#2 joins: 2 adds 2, 2 adds 1, 1 adds 2
#3 joins: 3 adds 3, 3 adds 1, 2 adds 3, 1 adds 3, 3 adds 2
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
#          |
#          |
#          V
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	#signal to main add_player
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	set_ID.emit(peer_id)
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	print("no server :( or connection failed")

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

func is_the_host():
	return multiplayer.is_server()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
