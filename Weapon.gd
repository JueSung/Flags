extends Area2D
class_name Weapon

var scenes = {
	"Laser" : preload("res://laser.tscn"),
	"Missle" : preload("res://missle.tscn"),
	"Platform" : preload("res://platform.tscn")
}
var melee = ["Laser"]

var left_charging = false
var right_charging = false
var third_charging = false

#var left_length = 1 #capsule height default 20, radius 10, changing height
#var left_length_default = 1
#var right_speed = 240 #figure out CHANGE
#var right_speed_default = 60

var current_ability = null #for melee abilities/abiilities that exist mutually exclusive of other abilities

var left_ability = []
var right_ability = []
var third_ability = []

var potential_ability_gains = {} #stringified reference as key to object


#0 = no resistance, otherwise, 2pi/rotational_resistance = radians per second able to move
var rotational_resistance = 0 #0 = no resistance, otherwise, radians per second able to move

var pre_pos = position
var pre_rot = rotation

var POS_DELTA_TOLERANCE = 0
var ROT_DELTA_TOLERANCE = 0

#testing 1 second cooldown
var left_cooldown_state = 1
var right_cooldown_state = 1
var third_cooldown_state = 1

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
	if get_parent().get_parent().my_ID == 1:
		connect("body_entered", body_entered)
		connect("body_exited", body_exited)
	


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
		rotation = fmod(rotation, 2 * PI) #keeps rotation between 0 and 2pi so doesn't spin infinitely
		rotation -= get_parent().rotation
		position = 60 * Vector2(cos(rotation), sin(rotation)).normalized()
		
		left_cooldown_state += delta
		if left_cooldown_state > 1:
			left_cooldown_state = 1
		get_parent().get_node("A1").set_percentage(left_cooldown_state)
		right_cooldown_state += delta
		if right_cooldown_state > 1:
			right_cooldown_state = 1
		get_parent().get_node("A2").set_percentage(right_cooldown_state)
		third_cooldown_state += delta
		if third_cooldown_state > 1:
			third_cooldown_state = 1
		get_parent().get_node("A3").set_percentage(third_cooldown_state)
		
		#charging weapons: hold to charge, release to fire
		#left mouse button---------------------------------------------------------------------------------------------
		if get_parent().left_click and left_cooldown_state>=1:
			left_charging = true
		elif left_charging:
			left_cooldown_state = 0
			left_charging = false
			#discharge ability
			for i in range(len(left_ability)):
				var ability = scenes[left_ability[i]].instantiate()
				ability.Ability(global_position, rotation)
				
				if left_ability[i] in melee:
					if current_ability == null:
						current_ability = ability
						add_child(ability)
						weapon_data["current_ability"] = current_ability.get_data()
					else:
						current_ability.stack(ability)
				else:
					get_parent().get_parent().add_child(ability)
			
			#var missle = preload("res://missle.tscn").instantiate()
			#missle.Ability(global_position, rotation)
			
			#get_parent().get_parent().add_child(missle)
		#----------------------------------------------------------------------------------------------------------------------------	
			
		#right mouse button---------------------------------------------------------------------------------------------
		if get_parent().right_click and right_cooldown_state >= 1:
			right_charging = true
			#charge_right stuff
			#if right_speed <= 1440 * 15: #15 seconds max charge
			#	right_speed += 1440 * delta
			
		elif right_charging:
			right_cooldown_state = 0
			right_charging = false
			#discharge
			for i in range(len(right_ability)):
				var ability = scenes[right_ability[i]].instantiate()
				ability.Ability(global_position, rotation)
				
				if right_ability[i] in melee:
					if current_ability == null:
						current_ability = ability
						add_child(ability)
						weapon_data["current_ability"] = current_ability.get_data()
					else:
						current_ability.stack(ability)
				else:
					get_parent().get_parent().add_child(ability)
			
			#var platform = preload("res://platform.tscn").instantiate()
			#platform.Ability(global_position, rotation)
			
			#get_parent().get_parent().add_child(platform)
		#----------------------------------------------------------------------------------------------------------------------------
		
		#third mouse button------------------------------------------------------------------
		if get_parent().side_mouse_click and third_cooldown_state >= 1:
			third_charging = true
		elif third_charging:
			third_cooldown_state = 0
			third_charging = false
			#discharge
			for i in range(len(third_ability)):
				var ability = scenes[third_ability[i]].instantiate()
				ability.Ability(global_position, rotation)
				
				if third_ability[i] in melee:
					if current_ability == null:
						current_ability = ability
						add_child(ability)
						weapon_data["current_ability"] = current_ability.get_data()
					else:
						current_ability.stack(ability)
				else:
					get_parent().get_parent().add_child(ability)
			
			#if current_ability == null:
				#discharge
				#SHABLAM
				#var laser = preload("res://laser.tscn").instantiate()
				#current_ability = laser
				
				#add_child(laser)
				#weapon_data["current_ability"] = current_ability.get_data() #must come after add_child
		#---------------------------------------------------------------------------------------------
		
		#handles gaining abilities
		if get_parent().E:
			#prioritizes left, right, third, so you don't dupe and get all 3
			if left_charging:
				left_charging = false #CHANGE: think about adding another var so you can with one hold pick up multiple abilities, but when release mouse key, doesn't launch ability
				for key in potential_ability_gains:
					left_ability.append(potential_ability_gains[key].ability_name)
					potential_ability_gains[key].queue_free()
				potential_ability_gains = {}
			elif right_charging:
				right_charging = false
				for key in potential_ability_gains:
					right_ability.append(potential_ability_gains[key].ability_name)
					potential_ability_gains[key].queue_free()
				potential_ability_gains = {}
			elif third_charging:
				third_charging = false
				for key in potential_ability_gains:
					third_ability.append(potential_ability_gains[key].ability_name)
					potential_ability_gains[key].queue_free()
				potential_ability_gains = {}
		#----------------------------------------------------------------------------------------------
			
		#multiplayer stuff
		if sqrt((position.x-pre_pos.x)**2 + (position.y - pre_pos.y)**2) >= POS_DELTA_TOLERANCE:
			weapon_data["position"] = position
		if abs(rotation - pre_rot) >= ROT_DELTA_TOLERANCE:
			weapon_data["rotation"] = rotation
		if current_ability != null:
			weapon_data["current_ability"] = current_ability.get_data()
		
		
		pre_pos = position
		pre_rot = rotation
	
func body_entered(body):
	potential_ability_gains[str(body)] = body
func body_exited(body):
	potential_ability_gains.erase(str(body))

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
