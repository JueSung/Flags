extends CharacterBody2D
class_name Player

var my_ID

const SPEED = 420
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 1470

#user inputs
var left = false
var right = false
var space = false
var left_click = false
var right_click = false
var side_mouse_click = false

var mouse_position = Vector2(0,0)
#--------

#player value things
var toastedness = 0
var heat_sources = 0
var TOASTEDNESS_TOLERANCE = 10 #if too toasted, catches on fire
var on_fire = false

#--------------------------------


#holds info like position, animation_frame, etc.
var player_data

func _ready():
	player_data = {
		"position" : position,
		"weapon_data" : $Weapon.weapon_data
	}


func _physics_process(delta):
	#only run if is server
	if get_parent().my_ID == 1:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta

		# Handle jump.
		if space and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = 0
		if right:
			direction += 1
		if left:
			direction -= 1
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		toastedness += heat_sources * delta
		
		if toastedness >= TOASTEDNESS_TOLERANCE and not on_fire: #only runs once
			on_fire = true
			print(self, " player is on fire lol" )
		
		
		move_and_slide()
		
		#update player_data
		player_data["position"] = position
		player_data["weapon_data"] = $Weapon.weapon_data

func add_heat_source():
	heat_sources += 1
func remove_heat_source():
	heat_sources -= 1
	
	

func die():
	print("I die")
	velocity = Vector2(0,0)
	position = Vector2(60,60)



#ran by clients to render game state
func update_game_state(player_dataa):
	position = player_dataa["position"]
	$Weapon.update_game_state(player_dataa["weapon_data"])
	
#ran by clients to update inputs
func update_inputs(inputs):
	left = inputs["left"]
	right = inputs["right"]
	space = inputs["space"]
	left_click = inputs["left_click"]
	right_click = inputs["right_click"]
	side_mouse_click = inputs["side_mouse_click"]
	mouse_position.x = inputs["mouse_position_x"]
	mouse_position.y = inputs["mouse_position_y"]
