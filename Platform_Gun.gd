extends Area2D
class_name Platform_Gun

var left_charging = false
var right_charging = false
var side_mouse_charging = false

var left_length = 1 #capsule height default 20, radius 10, changing height
var left_length_default = 1
var right_speed = 80 #figure out CHANGE
var right_speed_default = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	if get_parent().mouse_position.x - global_position.x != 0:
		rotation = atan2((get_parent().mouse_position.y - get_parent().global_position.y),(get_parent().mouse_position.x - get_parent().global_position.x))
	position = 20 * Vector2(cos(rotation), sin(rotation)).normalized()
	
	
	#charging weapons: hold to charge, release to fire
	if get_parent().left_click:
		left_charging = true
		#charge stuff
		left_length += .5 * delta
		
	elif left_charging:
		left_charging = false
		#discharge
		var laser = preload("res://missle.tscn").instantiate()
		laser.later_scale = left_length
		#laser.get_node("CollisionPolygon2D").polygon = PackedVector2Array([Vector2(-10,-10-left_length),Vector2(10,-10-left_length),\
		#Vector2(10,10+left_length),Vector2(-10,10+left_length)])
		laser.global_position = global_position + 20 * Vector2(cos(rotation),sin(rotation)).normalized()
		laser.velocity = 60 * Vector2(cos(rotation),sin(rotation)).normalized()
		if get_parent().mouse_position.x - global_position.x != 0:
			laser.rotation = rotation
		
		get_parent().get_parent().add_child(laser)
		
		left_length = left_length_default #default
	
	if get_parent().right_click:
		right_charging = true
		#charge_right stuff
		if right_speed <= 480 * 15: #15 seconds max charge
			right_speed += 480 * delta
		
	elif right_charging:
		right_charging = false
		#discharge
		var platform = preload("res://platform.tscn").instantiate()
		platform.get_node("CollisionPolygon2D").polygon = PackedVector2Array([Vector2(-15,-8),Vector2(15,-8),Vector2(15,8),Vector2(-15,8)])
		platform.global_position = global_position + 20 * Vector2(cos(rotation),sin(rotation)).normalized()
		platform.linear_velocity = right_speed * Vector2(cos(rotation),sin(rotation)).normalized()
		if get_parent().mouse_position.x - global_position.x != 0:
			platform.rotation = rotation
		get_parent().get_parent().add_child(platform)
		
		right_speed = right_speed_default
	
	#laser stuff
	if get_parent().side_mouse_click:
		side_mouse_charging = true
	elif side_mouse_charging:
		side_mouse_charging = false
		#discharge
		#SHABLAM
		var laser = preload("res://laser.tscn").instantiate()
		var space_state = get_world_2d().direct_space_state
	
	
	
		# Define the start and end points for the raycast
		var start_point = global_position
		var end_point = start_point + Vector2(cos(rotation),sin(rotation)) * 600 #start_point + direction * max laser len
		
		# Perform the raycast
		
		var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(start_point, end_point, collision_mask, [self, get_parent()]))
		
		if result:
			# Adjust laser length to the collision point
			var collision_point = result.position
			print(collision_point.x, ", ", collision_point.y)
			var distance = sqrt((global_position.x - result.position.x)**2 + (global_position.y - result.position.y)**2)
			laser.global_position = Vector2(distance/2 * cos(rotation) + global_position.x, distance/2 * sin(rotation) + global_position.y)
			laser.scale.x *= distance
			laser.rotation = rotation
			print(global_position)
			print(global_position.x + distance/2 * cos(rotation), ", ", global_position.y + distance/2*sin(rotation))
		else:
			# No collision, laser reaches maximum length
			print("hi")

		
		get_parent().get_parent().add_child(laser)
