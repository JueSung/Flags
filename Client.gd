extends Node2D
var inputs = {}
var TICK_RATE = 0.05 #20 ticks per second can change
var delta_accumulated
var my_ID
var in_a_game = false #only collects inputs if in a game

signal send_to_host(packet)


# Called when the node enters the scene tree for the first time.
func _ready():
	delta_accumulated = 0
	inputs = {
		"left" : false,
		"right" : false,
		"space" : false,
		"left_click" : false,
		"right_click" : false,
		"side_mouse_click" : false,
		"mouse_position_x" : 0,
		"mouse_position_y" : 0,
		"E" : false
	}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#delta_accumulated += delta
	#if delta_accumulated >= TICK_RATE and in_a_game:
		#delta_accumulated -= TICK_RATE
	inputs["left"] = Input.is_action_pressed("left")
	inputs["right"] = Input.is_action_pressed("right")
	inputs["space"] = Input.is_action_pressed("space")
	inputs["left_click"] = Input.is_action_pressed("left_click")
	inputs["right_click"] = Input.is_action_pressed("right_click")
	inputs["side_mouse_click"] = Input.is_action_pressed("side_mouse_click")

	inputs["mouse_position_x"] = get_viewport().get_mouse_position().x
	inputs["mouse_position_y"] = get_viewport().get_mouse_position().y
	
	inputs["E"] = Input.is_action_pressed("E")
	var packet = JSON.stringify(inputs)
	send_to_host.emit(packet)

#is called by main when game starts
func is_in_a_game(id):
	my_ID = id
	in_a_game = true
