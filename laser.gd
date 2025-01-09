extends Area2D
class_name Laser

var IS_MELEE = true #means projectiles cannot stack on, additional melee just changes rotation
var age = 0
var life_time = 5 #lives for x seconds
var full = false
var space_state
var max_len = 1350 #max len of laser
##var override_collision_position = Vector2(-500000,-500000)
var ROTATIONAL_RESISTANCE = 6
var position_offset #based on parent to get right outside range

var stacked #whether parent is player weapon or another ability
var objects_on_stack_chain = [] #lists objects part of stack chain so doesn't react with

#for sketch stuff:
#front section 109 pixels
#mid section 317 pixels
#end section 89 pixels
#------

var objects_touching = [] #objects already touching for when become full, kill those objects immediately bc area/body_entered doesn't trigger
var laser_data = {}

#constructor
func Ability(global_positionn_but_actually_position_offset, rotationn, stackedd):
	position_offset = global_positionn_but_actually_position_offset
	
	stacked = stackedd
	#start age lower than before full laser hitbox engaged because otherwise intersects parent from constructor
	if stacked:
		age = 2.4
		life_time += 2.5

# Called when the node enters the scene tree for the first time.
func _ready():
	laser_data["type"] = "laser"
	laser_data["position"] = position
	laser_data["scale"] = scale
	$AnimatedSprite2D1.hide()
	$AnimatedSprite2D2.hide()
	$AnimatedSprite2D3.hide()
	
	if get_tree().root.get_node("Main").my_ID == 1:
		objects_on_stack_chain.append(self)
		
		space_state = get_world_2d().direct_space_state
		connect("area_entered", area_entered)
		connect("area_exited", area_exited)
		connect("body_entered", body_entered)
		connect("body_exited", body_exited)
		
		position_offset = position_offset - get_parent().global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().root.get_node("Main").my_ID == 1:
		age += delta
		if (age >= 2.5 and not full):
			#SHABLAM
			full = true
			
			$CollisionShape2D.scale.y = 7
			if not stacked:
				get_parent().set_rotational_resistance(ROTATIONAL_RESISTANCE)
			
			#$AnimatedSprite2D1.show()
			#$AnimatedSprite2D2.show()
			#$AnimatedSprite2D3.show()
			
			for i in range(len(objects_touching)):
				##if objects_touching[i] in objects_on_stack_chain:
				##	print("ran")
				##	continue
				if objects_touching[i] is Missle:
					objects_touching[i].explode()
				#elif objects_touching[i] is Platform:
				#	objects_touching[i].queue_free()
				elif objects_touching[i] is Player: ##and objects_touching[i] != get_parent().get_parent():
					objects_touching[i].die()
				elif objects_touching[i] is Platform:
					objects_touching[i].add_heat_source()
			
		elif age >= life_time:
			die()
		
		# Define the start and end points for the raycast
		var start_point = get_parent().global_position + position_offset.length() * Vector2(cos(get_parent().rotation), sin(get_parent().rotation))
		var end_point = start_point + Vector2(cos(get_parent().rotation + rotation),sin(get_parent().rotation + rotation)) * max_len #start_point + direction * max laser len
		
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
			var distance = sqrt((start_point.x - result.position.x)**2 + (start_point.y - result.position.y)**2)
			#calculation for sprite info nums as follows:
			#201 -> len of start and end, which are not counted towards the shrinking of mid section
			#317.0 is num of pixels of mid section default amount to scale by
			#171 for 2D1 is point between start and mid as 146.3 is point between mid and end
			#0.35 is the original scale for sprite to match collision node
			$AnimatedSprite2D1.position.x = sprite_len/2.0 - distance/2.0# + sprite_offset#(1-(distance-198) / 317.0)* (171 + 23)
			$AnimatedSprite2D3.position.x = distance/2.0 - sprite_len/2.0# + sprite_offset#(1-(distance-198) / 317.0)* (-146.3 +23)
			$AnimatedSprite2D2.scale.x = -sprite_default_scale * (distance-(front_len + end_len)) / mid_len
			$AnimatedSprite2D2.position.x = (sprite_len/2.0 - front_len) * ((distance - (front_len+end_len)) /mid_len) - (distance / 2.0 - front_len)
			#print((sprite_len/2.0 - front_len) * ((distance - (front_len+end_len)) /mid_len) - (distance / 2.0 - front_len))
			#print((distance / 2.0 - end_len) - (sprite_len/2.0 - end_len) * ((distance - (front_len+end_len))/mid_len))
			#print(abs((sprite_len/2.0 - front_len) * ((distance - (front_len+end_len)) /mid_len) - (distance / 2.0 - front_len) - (distance / 2.0 - end_len) - (sprite_len/2.0 - end_len) * ((distance - (front_len+end_len))/mid_len)) <= 0.001)
			#-------------------------
			##if override_collision_position == Vector2(-500000, -500000):
			#$CollisionShape2D.position = get_parent().to_local(Vector2(distance/2 * cos(get_parent().rotation + rotation) + start_point.x, distance/2 * sin(get_parent().rotation + rotation) + start_point.y))
			$CollisionShape2D.global_position = start_point + distance / 2.0 * Vector2(cos(get_parent().rotation + rotation),sin(get_parent().rotation + rotation))
			$CollisionShape2D.scale.x = distance
				##override_collision_position = Vector2(-500000,-500000)
				
			$AnimatedSprite2D1.position += $CollisionShape2D.position
			$AnimatedSprite2D2.position += $CollisionShape2D.position
			$AnimatedSprite2D3.position += $CollisionShape2D.position
		else:
			# No collision, laser reaches maximum length
			#$CollisionShape2D.position = get_parent().to_local(Vector2(max_len/2 * cos(get_parent().rotation + rotation) + start_point.x, max_len/2 * sin(get_parent().rotation + rotation) + start_point.y))
			$CollisionShape2D.global_position = start_point + max_len / 2.0 * Vector2(cos(get_parent().rotation + rotation),sin(get_parent().rotation + rotation))
			
			$CollisionShape2D.scale.x = max_len
			$AnimatedSprite2D1.position.x = sprite_len/2.0 - max_len/2.0# + sprite_offset
			$AnimatedSprite2D3.position.x = max_len/2.0 - sprite_len/2.0# + sprite_offset
			$AnimatedSprite2D2.scale.x = -sprite_default_scale * (max_len-(front_len + end_len)) / mid_len
			$AnimatedSprite2D2.position.x = (sprite_len/2.0 - front_len) * ((max_len - (front_len+end_len)) /mid_len) - (max_len / 2.0 - front_len)
			
			$AnimatedSprite2D1.position += $CollisionShape2D.position
			$AnimatedSprite2D2.position += $CollisionShape2D.position
			$AnimatedSprite2D3.position += $CollisionShape2D.position
			
		
		laser_data["position"] = position
		laser_data["scale"] = scale

#if multiple melee weapons on self's parent, then each are offset in rotation relative to parent based on some calculation	
func set_rotation_offset(offset):
	rotation = offset

#need to change this stuff later--------

func get_data():
	return laser_data

func die():
	get_parent().lose_ability(str(self))
	queue_free()
	
#--------------------------------------
##func override_collision(pos):
##	var start_point = get_parent().global_position + position_offset.length() * Vector2(cos(get_parent().rotation - rotation), sin(get_parent().rotation - rotation))
##	var distance = sqrt((start_point.x - pos.x)**2 + (start_point.y - pos.y)**2)
##	position = get_parent().to_local(Vector2(distance/2 * cos(get_parent().rotation) + start_point.x, distance/2 * sin(get_parent().rotation) + start_point.y))
##	$CollisionShape2D.scale.x = distance
##	override_collision_position = pos


func area_entered(area):
	if full:
		if area in objects_on_stack_chain:
			return
		if area is Missle:
			area.explode()
	else:
		if area is Missle and area not in objects_on_stack_chain:
			objects_touching.append(area)


func body_entered(body):
	if full:
		if body in objects_on_stack_chain:
			return
		if body is Platform:
			body.add_heat_source()
		elif body is Player and body != get_parent().get_parent():
			body.die()
	else:
		if body is Platform or body is Player and body not in objects_on_stack_chain:
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
	$CollisionShape2D.position = laser_dataa["position"]
	$CollisionShape2D.scale = laser_dataa["scale"]
	
