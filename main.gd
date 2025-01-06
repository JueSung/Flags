extends Node
var my_ID
var player_datas = {}
var player_objects = {}
var players_IDs = [] #for host, in order as joined from host perspective
var users_inputs = {} #map w/ key of user inputs value of map of inputs from client

# literally just key as stringified version of reference and value is reference for server
#for client, same, but their values will look different bc key corresponds to server version
var objects = {}
var objects_data = {}
var objects_to_be_deleted = [] #to send to clients


var map

#Game Constants Stuff that various stuff needs to know that I don't want to repeat in every node------------------------
var MELEE_ABILITIES = ["Laser"]


#-----------------------------------------------------------------------------------------------------------------------


func _ready():
	$HUD.show()
	$Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

func set_ID(id):
	my_ID = id

func host_game():
	$Lobby.create_game()
	$HUD.host_game()

#used first to get ip page
func join_game():
	$HUD.join_game()

#second join game press to join game for real cuz have ip now
func join_game2():
	$Lobby.join_game()
	$HUD.join_game2()

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
		
	players_IDs.append(peer_id)

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
	if not $Lobby.multiplayer.is_server():
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

#will need to combine VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

#recieve and update player game states from host
@rpc("any_peer","reliable")
func update_clients_player_game_state(id, player_data):
	#if player_id in players:
	player_objects[id].update_game_state(player_data)
	player_datas[id] = player_data
	
@rpc ("any_peer", "reliable")
func update_clients_object_game_state(objects_dataa):
	for key in objects_dataa:
		if key not in objects: #then it will "type" key in its object_data
			var object
			match objects_dataa[key]["type"]:
				"platform":
					object = preload("res://platform.tscn").instantiate()
					var d = objects_dataa[key]
					object.Platform(d["x"], d["y"], d["position"], d["rotation"], Vector2(0,0), false)
				"missle":
					object = preload("res://missle.tscn").instantiate()
					var d = objects_dataa[key]
					object.position = d["position"]
				_:
					print("unknown dun dun dunnnnn!!!")
					continue
			add_child(object)
			objects[str(key)] = object
			#don't think objects_data needs to be updated for client side
		else:
			objects[key].update_data(objects_dataa[key])

@rpc("any_peer", "reliable")
func client_delete_objects(objects_to_be_deletedd):
	# "o" var is stringified reference name => key in objects & objects_data
	for o in objects_to_be_deletedd:
		objects[o].queue_free()
		objects.erase(o)
		objects_data.erase(o)

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

func start_game():
	$HUD.hide()
	
	if $Lobby.is_the_host():
		rpc("recieve_start_game")
	
	if my_ID == 1:
		map = preload("res://Maps/map_1.tscn").instantiate()
		map.Map(1) #constructor instantiates map type 1
		add_child(map)
		#add_child(preload("res://rope.tscn").instantiate())
	var count = 0
	#create player objects
	for peer_id in players_IDs:
		#create players
		var player_instance = preload("res://player.tscn").instantiate()
		player_instance.my_ID = peer_id
		player_instance.position.x += 20 * count + 300
		player_instance.position.y = 100
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
	
		#get info and update rendering clients with player game states
		for id in player_objects:
			#update and send outplayer data game states
			player_datas[id] = player_objects[id].player_data
			var player_data = player_datas[id]
			rpc("update_clients_player_game_state", id, player_data)
		for object in objects:
			objects_data[object] = objects[object].get_data()
		rpc("update_clients_object_game_state", objects_data)
		objects_data = {}
		rpc("client_delete_objects", objects_to_be_deleted)
		objects_to_be_deleted = []


#game stuff

#string reference different than reference depending if server or not
func delete_object(string_reference, reference):
	objects.erase(string_reference)
	objects_data.erase(string_reference)
	reference.queue_free()
	objects_to_be_deleted.append(string_reference)
