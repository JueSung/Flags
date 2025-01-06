extends Area2D
class_name Weapon

var scenes = {
	"Laser" : preload("res://laser.tscn"),
	"Missle" : preload("res://missle.tscn"),
	"Platform" : preload("res://platform.tscn")
}
var MELEE_ABILITIES

var left_charging = false
var right_charging = false
var third_charging = false

#var left_length = 1 #capsule height default 20, radius 10, changing height
#var left_length_default = 1
#var right_speed = 240 #figure out CHANGE
#var right_speed_default = 60

var current_ability = null #for melee abilities/abiilities that exist mutually exclusive of other abilities

var left_active_ability = {}
var right_active_ability = {}
var third_active_ability = {}

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
	
	
	MELEE_ABILITIES = get_parent().get_parent().MELEE_ABILITIES
	


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
			var stacking_next_on = null
			for i in range(len(left_ability)):
				var ability = scenes[left_ability[i]].instantiate()
				if stacking_next_on == null:
					if not ability.IS_MELEE:
						stacking_next_on = ability
				else:
					stacking_next_on.stack_ability(ability)
					continue
				#When calling .Ability(pos,rot, stacked), the parent must make the position right outside its hitbox area, 
				#and so the instantiated object will adjust the position based on its center so it remains outside
				#"stacked" is whether the ability's parent is another ability (true) or the player's weapon_slot (false)
				ability.Ability(global_position+30 * Vector2(cos(rotation),sin(rotation)).normalized(), rotation, false)
				
				if left_ability[i] in MELEE_ABILITIES:
					add_child(ability)
					left_active_ability[str(ability)] = ability
					
					var count = 0
					for key in left_active_ability:
						left_active_ability[key].set_rotation_offset(int((count+1)/2) * PI/4.0 * (-1 * (-2 * (count % 2) + 1))\
						 - PI/8.0 * ((left_active_ability.size()+1) % 2))
						count += 1
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
			
		elif right_charging:
			right_cooldown_state = 0
			right_charging = false
			#discharge
			var stacking_next_on = null #used if stacking abilities on projectile
			for i in range(len(right_ability)):
				var ability = scenes[right_ability[i]].instantiate()
				if stacking_next_on == null:
					if not ability.IS_MELEE:
						stacking_next_on = ability
				else:
					stacking_next_on.stack_ability(ability)
					continue
				ability.Ability(global_position +30 * Vector2(cos(rotation),sin(rotation)).normalized(), rotation, false)
				
				if right_ability[i] in MELEE_ABILITIES:
					add_child(ability)
					right_active_ability[str(ability)] = ability
					
					var count = 0
					for key in right_active_ability:
						right_active_ability[key].set_rotation_offset(int((count+1)/2) * PI/4.0 * (-1 * (-2 * (count % 2) + 1))\
						 - PI/8.0 * ((right_active_ability.size()+1) % 2))
						count += 1
				else:
					get_parent().get_parent().add_child(ability)
		#----------------------------------------------------------------------------------------------------------------------------
		#third mouse button------------------------------------------------------------------
		if get_parent().side_mouse_click and third_cooldown_state >= 1:
			third_charging = true
		elif third_charging:
			third_cooldown_state = 0
			third_charging = false
			#discharge
			var stacking_next_on = null
			for i in range(len(third_ability)):
				var ability = scenes[third_ability[i]].instantiate()
				if stacking_next_on == null:
					if not ability.IS_MELEE:
						stacking_next_on = ability
				else:
					stacking_next_on.stack_ability(ability)
					continue
				
				ability.Ability(global_position+30 * Vector2(cos(rotation),sin(rotation)).normalized(), rotation, false)
				
				if third_ability[i] in MELEE_ABILITIES:
					#add must come before adding to map because reference changes after add_child()
					add_child(ability)
					third_active_ability[str(ability)] = ability
					var count = 0
					for key in third_active_ability:
						third_active_ability[key].set_rotation_offset(int((count+1)/2) * PI/4.0 * (-1 * (-2 * (count % 2) + 1))\
						 - PI/8.0 * ((third_active_ability.size()+1) % 2))
						count += 1
						
					
					"""if current_ability == null:
						current_ability = ability
						add_child(ability)
						weapon_data["current_ability"] = current_ability.get_data()
					else:
						current_ability.stack(ability)"""
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
					if not potential_ability_gains[key].ability_name in MELEE_ABILITIES:
						if len(left_ability) > 0 and left_ability[-1] in MELEE_ABILITIES:
							continue
					left_ability.append(potential_ability_gains[key].ability_name)
					potential_ability_gains[key].queue_free()
					potential_ability_gains.erase(str(potential_ability_gains[key]))
				#potential_ability_gains = {}
			elif right_charging:
				right_charging = false
				for key in potential_ability_gains:
					if not potential_ability_gains[key].ability_name in MELEE_ABILITIES:
						if len(right_ability) > 0 and right_ability[-1] in MELEE_ABILITIES:
							continue
					right_ability.append(potential_ability_gains[key].ability_name)
					potential_ability_gains[key].queue_free()
					potential_ability_gains.erase(str(potential_ability_gains[key]))
			elif third_charging:
				third_charging = false
				for key in potential_ability_gains:
					if not potential_ability_gains[key].ability_name in MELEE_ABILITIES:
						if len(third_ability) > 0 and third_ability[-1] in MELEE_ABILITIES:
							continue
					third_ability.append(potential_ability_gains[key].ability_name)
					potential_ability_gains[key].queue_free()
					potential_ability_gains.erase(str(potential_ability_gains[key]))
			print(potential_ability_gains)
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


func lose_ability(stringified_reference):
	#ability itself handles queue_free()
	if left_active_ability.has(stringified_reference):
		left_active_ability.erase(stringified_reference)
	elif right_active_ability.has(stringified_reference):
		right_active_ability.erase(stringified_reference)
	elif third_active_ability.has(stringified_reference):
		third_active_ability.erase(stringified_reference)
	else:
		print("USER DEFINED ERROR: melee ability being destroyed but not found in active ability maps")
	
	#CHANGE will need to update based on what is rotational resistance affected by when multiple abilities present
	if left_active_ability.is_empty() and right_active_ability.is_empty() and third_active_ability.is_empty():
		rotational_resistance = 0
	
	#current_ability.queue_free()
	#current_ability = null
	#rotational_resistance = 0
	#weapon_data["objects_to_be_destroyed"] = 1
	


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
				pass
				#lose_ability()
