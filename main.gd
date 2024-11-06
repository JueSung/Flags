extends Node
var my_ID
var player_datas = {}
var player_objects = {}
var players_IDs = [] #for host, in order as joined from host perspective
var users_inputs = {} #map w/ key of user inputs value of map of inputs from client

var map

func _ready():
	$HUD.show()
	$Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

func set_ID(id):
	my_ID = id

func host_game():
	$Lobby.create_game()
	$HUD.host_game()

func join_game():
	$Lobby.join_game()
	$HUD.join_game()

#undos host_game and join_game if you were to go back to title screen
func un_host_join_game():
	#clear all data
	player_datas = {}
	player_objects = {}
	players_IDs = []
	#need to clear all child nodes, players, etc.
	
	
	$Lobby.remove_multiplayer_peer()
	$HUD.back_to_title()

#recieved from lobby when player joins
func add_player(peer_id, _player_info): #idk player_info is unused
	if my_ID == 1:
		print(peer_id)
		
	players_IDs.append(peer_id)
	if my_ID == 1:
		print(players_IDs)

#signal recieved from lobby if any peer disconnects
func player_disconnected(peer_id):
	players_IDs.remove_at(players_IDs.find(peer_id))

func server_disconnected():
	#return to home screen
	print("server disconnected...")
	un_host_join_game()

#from client node, sending inputs from client
#sending to server
func send_inputs_to_main(packet):
	if my_ID != 1:
		#
		rpc_id(1, "recieve_client_inputs",my_ID, packet)
	else:
		recieve_client_inputs(1,packet)

#recieving client inputs from clients
#ran by host only
@rpc("any_peer","reliable")
func recieve_client_inputs(id, packet):
	var inputs = JSON.parse_string(packet)
	users_inputs[id] = inputs

#recieve and update player game states from host
@rpc("any_peer","reliable")
func update_clients_player_game_state(id, player_data):
	#if player_id in players:
	player_objects[id].update_game_state(player_data)
	player_datas[id] = player_data

func start_game():
	$HUD.hide()
	
	if $Lobby.is_the_host():
		rpc("recieve_start_game")
		
	map = preload("res://Maps/map_1.tscn").instantiate()
	add_child(map)
	var count = 0
	#create player objects
	for peer_id in players_IDs:
		#create players
		var player_instance = preload("res://player.tscn").instantiate()
		player_instance.my_ID = peer_id
		player_instance.position.x += 20 * count + 20
		player_instance.position.y = 20
		#adding child makes _ready() run so intialize other vars before
		player_objects[peer_id] = player_instance
	
		add_child(player_instance)
		count += 1
		
	
	$Client.is_in_a_game(my_ID)

#function that just recieves from host to start game then calls start_game
@rpc("any_peer","reliable")
func recieve_start_game():
	start_game()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#only server runs
	if my_ID == 1:
		
		#update server players with input values
		for id in player_objects:
			if id in users_inputs:
				player_objects[id].update_inputs(users_inputs[id])
	
		#update rendering clients with player game states
		for id in player_objects:
			#update and send outplayer data game states
			player_datas[id] = player_objects[id].player_data
			var player_data = player_datas[id]
			rpc("update_clients_player_game_state", id, player_data)
