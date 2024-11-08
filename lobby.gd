extends Node
class_name Lobby

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

signal set_ID(peer_id)

var server_ip = "localhost"
var server_port = 8080
var MAX_CONNECTIONS = 8

#dictionary containing player info and player id as keys
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

var players_loaded = 0




func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_game():
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
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(server_ip, server_port)
	if result != OK:
		print("Failed to connect to server")
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
