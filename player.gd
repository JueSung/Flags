extends CharacterBody2D
class_name Player

var my_ID

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 1470 * 1.5

const SPEED = 420 * 1.5
var JUMP_VELOCITY = -1 * sqrt(gravity * 2 * 240)

var AIR_FRICTION = 420

var surface = null#NEW



#user inputs
var left = false
var right = false
var space = false
var left_click = false
var right_click = false
var side_mouse_click = false

var mouse_position = Vector2(0,0)

var E = false
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
	$AnimatedSprite2D.animation = "Marshmallow1"
	player_data = {
		"position" : position,
		"weapon_data" : $Weapon.weapon_data
	}


func _physics_process(delta):
	#only run if is server
	if get_parent().my_ID == 1:
		#new
		#if get_slide_collision_count() > 0:
			#surface = get_slide_collision(0)
			#rotation = atan2(surface.get_normal().x, -1*surface.get_normal().y)
		#else:
		#	surface = null
		
		# Add the gravity.
		if not is_on_floor():#dum stuff && not is_on_ceiling() and not is_on_wall():#newsurface == null:
			#gravity increases by 50% when falling to make jumping feel better
			#falling is velocity.y > 0 bc down is +y
			if velocity.y <= 0 || space:
				velocity.y += gravity * delta
			else:
				velocity.y += gravity * 1.5 * delta 

		# Handle jump.
		if space and is_on_floor():#dum stuff or is_on_ceiling() or is_on_wall()): #newsurface != null:
			#if is_on_floor():
			#	up_direction = -1 * get_floor_normal()
			#elif is_on_ceiling():
			#	up_direction = -1 * Vector2(1,0) #idk why no get_ceiling_normal()
			#elif is_on_wall():
			#	up_direction = -1 * get_wall_normal()
			velocity.y = JUMP_VELOCITY
			#velocity.y = JUMP_VELOCITY
		
		#when space stops being pressed, stops moving up on jump
		elif not space and not is_on_floor() and velocity.y < 0:
			velocity.y -= (5 * velocity.y) * delta


		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = 0
		if right:
			direction += 1
		if left:
			direction -= 1
		
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta * 30)
			#if surface:
			#	velocity = Vector2(surface.get_normal().y * -1, surface.get_normal().x) * direction * SPEED
			#else:
			#	velocity.x = direction * SPEED
			if direction >= 0:
				$AnimatedSprite2D.scale = Vector2(abs($AnimatedSprite2D.scale.x), abs($AnimatedSprite2D.scale.y))
			else:
				$AnimatedSprite2D.scale = Vector2(abs($AnimatedSprite2D.scale.x)*-1, abs($AnimatedSprite2D.scale.y))
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.stop()
			
			#way to slow down velocity when not inputs not right or left
			#going from in velocity.x direction decreasing speed til 0, rate of 20 * SPEED * delta per frame aka 20 * SPEED per second
			#aka to 0 in .05 seconds
			velocity.x = move_toward(velocity.x, 0, 20 * SPEED * delta)
			#newvelocity.y = move_toward(velocity.y, 0, SPEED)
		
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
	E = inputs["E"]
