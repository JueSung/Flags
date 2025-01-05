extends Area2D
class_name Laser
var life_time = 5 #lives for x seconds
var full = false
var space_state
var max_len = 1350 #max len of laser
var override_collision_position = Vector2(-500000,-500000)

var stacked_ability = null

#for sketch stuff:
#front section 109 pixels
#mid section 317 pixels
#end section 89 pixels
#------

var objects_touching = [] #objects already touching for when become full, kill those objects immediately bc area/body_entered doesn't trigger
var laser_data = {}

#constructor
func Ability(global_positionn_, rotationn):
	pass #doesn't actually need to do anything

# Called when the node enters the scene tree for the first time.
func _ready():
	laser_data["type"] = "laser"
	laser_data["position"] = position
	laser_data["scale"] = scale
	$AnimatedSprite2D1.hide()
	$AnimatedSprite2D2.hide()
	$AnimatedSprite2D3.hide()
	
	if get_parent().get_parent().get_parent().my_ID == 1:
		space_state = get_world_2d().direct_space_state
		connect("area_entered", area_entered)
		connect("area_exited", area_exited)
		connect("body_entered", body_entered)
		connect("body_exited", body_exited)
		
		get_parent().set_rotational_resistance(6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().get_parent().get_parent().my_ID == 1:
		life_time -= delta
		if (life_time <= 3.5 and not full):
			#SHABLAM
			full = true
			
			$CollisionShape2D.scale.y = 7
			
			#$AnimatedSprite2D1.show()
			#$AnimatedSprite2D2.show()
			#$AnimatedSprite2D3.show()
			
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
		var ray_param = PhysicsRayQueryParameters2D.create(start_point, end_point, collision_mask, [self, get_parent(), get_parent().get_parent()])
		#ray_param.set_collide_with_areas(true)
		var result = space_state.intersect_ray(ray_param)
		
		
		var sprite_len = 516.0
		var sprite_offset = 23.5+15
		var sprite_default_scale = .35
		var front_len = 100.4
		var mid_len = 317.6
		var end_len = 98
		
		if result:
			# Adjust laser length to the collision point
			var collision_point = result.position
			var distance = sqrt((get_parent().global_position.x - result.position.x)**2 + (get_parent().global_position.y - result.position.y)**2)
			#calculation for sprite info nums as follows:
			#201 -> len of start and end, which are not counted towards the shrinking of mid section
			#317.0 is num of pixels of mid section default amount to scale by
			#171 for 2D1 is point between start and mid as 146.3 is point between mid and end
			#0.35 is the original scale for sprite to match collision node
			$AnimatedSprite2D1.position.x = sprite_len/2.0 - distance/2.0# + sprite_offset#(1-(distance-198) / 317.0)* (171 + 23)
			$AnimatedSprite2D3.position.x = distance/2.0 - sprite_len/2.0# + sprite_offset#(1-(distance-198) / 317.0)* (-146.3 +23)
			$AnimatedSprite2D2.scale.x = -sprite_default_scale * (distance-(front_len + end_len)) / mid_len
			$AnimatedSprite2D2.position.x = (sprite_len/2.0 - front_len) * ((distance - (front_len+end_len)) /mid_len) - (distance / 2.0 - front_len)
			print((sprite_len/2.0 - front_len) * ((distance - (front_len+end_len)) /mid_len) - (distance / 2.0 - front_len))
			print((distance / 2.0 - end_len) - (sprite_len/2.0 - end_len) * ((distance - (front_len+end_len))/mid_len))
			print(abs((sprite_len/2.0 - front_len) * ((distance - (front_len+end_len)) /mid_len) - (distance / 2.0 - front_len) - (distance / 2.0 - end_len) - (sprite_len/2.0 - end_len) * ((distance - (front_len+end_len))/mid_len)) <= 0.001)
			#-------------------------
			if override_collision_position == Vector2(-500000, -500000):
				position = get_parent().to_local(Vector2(distance/2 * cos(get_parent().rotation) + get_parent().global_position.x, distance/2 * sin(get_parent().rotation) + get_parent().global_position.y))
				$CollisionShape2D.scale.x = distance
				override_collision_position = Vector2(-500000,-500000)
		else:
			# No collision, laser reaches maximum length
			position = get_parent().to_local(Vector2(max_len/2 * cos(get_parent().rotation) + get_parent().global_position.x, max_len/2 * sin(get_parent().rotation) + get_parent().global_position.y))
			$CollisionShape2D.scale.x = max_len
			$AnimatedSprite2D1.position.x = sprite_len/2.0 - max_len/2.0# + sprite_offset
			$AnimatedSprite2D3.position.x = max_len/2.0 - sprite_len/2.0# + sprite_offset
			$AnimatedSprite2D2.scale.x = -sprite_default_scale * (max_len-(front_len + end_len)) / mid_len
			$AnimatedSprite2D2.position.x = (sprite_len/2.0 - front_len) * ((max_len - (front_len+end_len)) /mid_len) - (max_len / 2.0 - front_len)
			
			
			
		
		laser_data["position"] = position
		laser_data["scale"] = scale

#need to change this stuff later---------
func set_rotational_resistance(num_):
	pass
func lose_ability():
	pass
func stack(ability):
	if stacked_ability == null:
		stacked_ability = ability
		add_child(ability)
	else:
		stacked_ability.stack(ability)

func get_data():
	return laser_data

func die():
	get_parent().lose_ability()
	#parent will queue_free
	
	#CHANGE
	if stacked_ability != null:
		stacked_ability.die()
#--------------------------------------
func override_collision(pos):
	var distance = sqrt((get_parent().global_position.x - pos.x)**2 + (get_parent().global_position.y - pos.y)**2)
	position = get_parent().to_local(Vector2(distance/2 * cos(get_parent().rotation) + get_parent().global_position.x, distance/2 * sin(get_parent().rotation) + get_parent().global_position.y))
	$CollisionShape2D.scale.x = distance
	override_collision_position = pos


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
	$CollisionShape2D.scale = laser_dataa["scale"]
	
