extends Area2D
class_name Platform_Gun

var left_charging = false
var right_charging = false
var side_mouse_charging = false

var left_length = 1 #capsule height default 20, radius 10, changing height
var left_length_default = 1
var right_speed = 80 #figure out CHANGE
var right_speed_default = 20

var current_ability = null #for melee abilities/abiilities that exist mutually exclusive of other abilities

#0 = no resistance, otherwise, 2pi/rotational_resistance = radians per second able to move
var rotational_resistance = 0 #0 = no resistance, otherwise, radians per second able to move

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	#rotation calculation
	var target_rot = 0
	if get_parent().mouse_position.x - global_position.x != 0:
		target_rot = atan2((get_parent().mouse_position.y - get_parent().global_position.y),(get_parent().mouse_position.x - get_parent().global_position.x))
	if rotational_resistance == 0 or abs(rotation - target_rot) <= 2 * PI / rotational_resistance * delta:
		rotation = target_rot
	else:
		rotation += (target_rot - rotation) / abs(target_rot - rotation) * 2 * PI / rotational_resistance * delta
	
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
		laser.velocity = 600 * Vector2(cos(rotation),sin(rotation)).normalized()
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
		var rot = 0
		if get_parent().mouse_position.x - global_position.x != 0:
			rot = rotation
		platform.Platform(30,16,global_position + 20 * Vector2(cos(rotation), sin(rotation)).normalized(), rot, right_speed * Vector2(cos(rotation), sin(rotation)).normalized())
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

func set_rotational_resistance(res):
	rotational_resistance = res


func lose_ability(): #current_ability == null
	current_ability = null
	rotational_resistance = 0
