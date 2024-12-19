extends Area2D
class_name Laser
var life_time = 5 #lives for x seconds
var full = false
var space_state
var max_len = 1350 #max len of laser

var objects_touching = [] #objects already touching for when become full, kill those objects immediately bc area/body_entered doesn't trigger
var laser_data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	laser_data["type"] = "laser"
	laser_data["position"] = position
	laser_data["scale"] = scale
	
	if get_parent().get_parent().get_parent().my_ID == 1:
		space_state = get_world_2d().direct_space_state
		connect("area_entered", area_entered)
		connect("area_exited", area_exited)
		connect("body_entered", body_entered)
		connect("body_exited", body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().get_parent().get_parent().my_ID == 1:
		life_time -= delta
		if (life_time <= 3.5 and not full):
			full = true
			get_parent().set_rotational_resistance(6)
			scale.y = 7
			
			for i in range(len(objects_touching)):
				if objects_touching[i] is Missle:
					objects_touching[i].explode()
				#elif objects_touching[i] is Platform:
				#	objects_touching[i].queue_free()
				elif objects_touching[i] is Player:
					objects_touching[i].die()
				elif objects_touching[i] is Platform:
					objects_touching[i].add_heat_source()
			
		elif life_time <= 0:
			die()
		
		# Define the start and end points for the raycast
		var start_point = get_parent().global_position
		var end_point = start_point + Vector2(cos(get_parent().rotation),sin(get_parent().rotation)) * max_len #start_point + direction * max laser len
		
		# Perform the raycast
		
		var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(start_point, end_point, collision_mask, [self, get_parent(), get_parent().get_parent()]))
		
		if result:
			# Adjust laser length to the collision point
			var collision_point = result.position
			var distance = sqrt((get_parent().global_position.x - result.position.x)**2 + (get_parent().global_position.y - result.position.y)**2)
			position = get_parent().to_local(Vector2(distance/2 * cos(get_parent().rotation) + get_parent().global_position.x, distance/2 * sin(get_parent().rotation) + get_parent().global_position.y))
			scale.x = distance
		else:
			# No collision, laser reaches maximum length
			position = get_parent().to_local(Vector2(max_len/2 * cos(get_parent().rotation) + get_parent().global_position.x, max_len/2 * sin(get_parent().rotation) + get_parent().global_position.y))
			scale.x = max_len
			
			
		
		laser_data["position"] = position
		laser_data["scale"] = scale
	
func get_data():
	return laser_data

func die():
	get_parent().lose_ability()
	#parent will queue_free


func area_entered(area):
	if full:
		if area is Missle:
			area.explode()
	else:
		if area is Missle:
			objects_touching.append(area)


func body_entered(body):
	if full:
		if body is Platform:
			body.add_heat_source()
		elif body is Player:
			body.die()
	else:
		if body is Platform or body is Player:
			objects_touching.append(body)


func area_exited(area):
	if not full and (area is Missle):
		if objects_touching.find(area) != -1:
			objects_touching.erase(area)

func body_exited(body):
	if not full and (body is Platform or body is Player):
		if objects_touching.find(body) != -1:
			objects_touching.erase(body)
	elif full:
		if body is Platform:
			body.remove_heat_source()


func update_data(laser_dataa):
	position = laser_dataa["position"]
	scale = laser_dataa["scale"]
	
