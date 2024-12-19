extends Area2D
class_name Weapon

var left_charging = false
var right_charging = false
var side_mouse_charging = false

var left_length = 1 #capsule height default 20, radius 10, changing height
var left_length_default = 1
var right_speed = 240 #figure out CHANGE
var right_speed_default = 60

var current_ability = null #for melee abilities/abiilities that exist mutually exclusive of other abilities

#0 = no resistance, otherwise, 2pi/rotational_resistance = radians per second able to move
var rotational_resistance = 0 #0 = no resistance, otherwise, radians per second able to move

var pre_pos = position
var pre_rot = rotation

var POS_DELTA_TOLERANCE = 0
var ROT_DELTA_TOLERANCE = 0

var weapon_data # =  {
#	'position' = position,
#	'rotation' = rotation,
#	'objects_to_be_created' = [],
#	'objects_to_be_destroyed' = [],
#	'current_ability' = current_ability	
#}

var objects_to_be_deleted = []


# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_data = {}
	pre_pos = position
	pre_rot = rotation


func _process(delta):
	if get_parent().get_parent().my_ID == 1:
		weapon_data = {}
		#rotation calculation
		var target_rot = 0
		if get_parent().mouse_position.x - global_position.x != 0:
			target_rot = atan2((get_parent().mouse_position.y - get_parent().global_position.y),(get_parent().mouse_position.x - get_parent().global_position.x))
		if rotational_resistance == 0 or abs(rotation - target_rot) <= 2 * PI / rotational_resistance * delta:
			rotation = target_rot
		else:
			rotation += (int((abs(target_rot - rotation) <= PI))* 2 - 1) * (target_rot - rotation) / abs(target_rot - rotation) * 2 * PI / rotational_resistance * delta
		
		position = 60 * Vector2(cos(rotation), sin(rotation)).normalized()
		
		#charging weapons: hold to charge, release to fire
		if get_parent().left_click:
			left_charging = true
			#charge stuff
			left_length += 1.5 * delta
			
		elif left_charging:
			left_charging = false
			#discharge
			var missle = preload("res://missle.tscn").instantiate()
			missle.later_scale = left_length
			#laser.get_node("CollisionPolygon2D").polygon = PackedVector2Array([Vector2(-10,-10-left_length),Vector2(10,-10-left_length),\
			#Vector2(10,10+left_length),Vector2(-10,10+left_length)])
			missle.global_position = global_position + 60 * Vector2(cos(rotation),sin(rotation)).normalized()
			missle.velocity = 1800 * Vector2(cos(rotation),sin(rotation)).normalized()
			if get_parent().mouse_position.x - global_position.x != 0:
				missle.rotation = rotation
			
			get_parent().get_parent().add_child(missle)
			
			left_length = left_length_default #default
		
		if get_parent().right_click:
			right_charging = true
			#charge_right stuff
			if right_speed <= 1440 * 15: #15 seconds max charge
				right_speed += 1440 * delta
			
		elif right_charging:
			right_charging = false
			#discharge
			var platform = preload("res://platform.tscn").instantiate()
			var rot = 0
			if get_parent().mouse_position.x - global_position.x != 0:
				rot = rotation
			platform.Platform(90,48,global_position + 60 * Vector2(cos(rotation), sin(rotation)).normalized(), rot, right_speed * Vector2(cos(rotation), sin(rotation)).normalized(), true)
			get_parent().get_parent().add_child(platform)
			
			right_speed = right_speed_default
		
		#laser stuff
		if get_parent().side_mouse_click:
			side_mouse_charging = true
		elif side_mouse_charging:
			side_mouse_charging = false
			if current_ability == null:
				#discharge
				#SHABLAM
				var laser = preload("res://laser.tscn").instantiate()
				current_ability = laser
				
				add_child(laser)
				weapon_data["current_ability"] = current_ability.get_data() #must come after add_child
		
		
		
		#multiplayer stuff
		if sqrt((position.x-pre_pos.x)**2 + (position.y - pre_pos.y)**2) >= POS_DELTA_TOLERANCE:
			weapon_data["position"] = position
		if abs(rotation - pre_rot) >= ROT_DELTA_TOLERANCE:
			weapon_data["rotation"] = rotation
		if current_ability != null:
			weapon_data["current_ability"] = current_ability.get_data()
		
		
		pre_pos = position
		pre_rot = rotation
	
	

func set_rotational_resistance(res):
	rotational_resistance = res


func lose_ability(): #current_ability == null
	current_ability.queue_free()
	current_ability = null
	rotational_resistance = 0
	weapon_data["objects_to_be_destroyed"] = 1
	


func update_game_state(weapon_dataa):
	for key in weapon_dataa:
		match key:
			"position":
				position = weapon_dataa[key]
			"rotation":
				rotation = weapon_dataa[key]
			"current_ability": #instantiate ability
				if current_ability == null:
					match weapon_dataa[key]["type"]:
						"laser":
							current_ability = preload("res://laser.tscn").instantiate()
							current_ability.update_data(weapon_dataa[key])
							add_child(current_ability)
				else:
					current_ability.update_data(weapon_dataa[key])
			"objects_to_be_destroyed": #only used right now for current ability, if multiple objects need to rewrite, also look at last line of lose_ability()
				lose_ability()
