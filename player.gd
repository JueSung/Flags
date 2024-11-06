extends CharacterBody2D
var my_ID

const SPEED = 140.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 490

#user inputs
var left = false
var right = false
var space = false
var left_click = false
var right_click = false

var mouse_position = Vector2(0,0)

#holds info like position, animation_frame, etc.
var player_data

func _ready():
	player_data = {
		"position" : position
	}
	if my_ID == 1:
		var platform = preload("res://platform.tscn").instantiate()
		platform.get_node("CollisionShape2D").shape.extents = Vector2(50,50)
		get_parent().add_child(platform)
		platform.position = Vector2(200, 50)
		platform.linear_velocity = Vector2(600,0)


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
		
		move_and_slide()
		
		#update player_data
		player_data["position"] = position

#ran by clients to render game state
func update_game_state(player_dataa):
	position = player_dataa["position"]
	
#ran by clients to update inputs
func update_inputs(inputs):
	left = inputs["left"]
	right = inputs["right"]
	space = inputs["space"]
	left_click = inputs["left_click"]
	right_click = inputs["right_click"]
	mouse_position.x = inputs["mouse_position_x"]
	mouse_position.y = inputs["mouse_position_y"]
