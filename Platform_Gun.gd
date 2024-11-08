extends Area2D
class_name Platform_Gun

var left_charging = false
var right_charging = false

var left_length = 20 #capsule height default 20, radius 10, changing height
var left_length_default = 20
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
		left_length += 40 * delta
		
	elif left_charging:
		left_charging = false
		#discharge
		var laser = preload("res://laser.tscn").instantiate()
		laser.get_node("CollisionShape2D").shape = CapsuleShape2D.new()
		laser.get_node("CollisionShape2D").shape.height = left_length
		laser.global_position = global_position + 20 * Vector2(cos(rotation),sin(rotation)).normalized()
		laser.linear_velocity = 600 * Vector2(cos(rotation),sin(rotation)).normalized()
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
		platform.get_node("Area2D").get_node("CollisionPolygon2D").polygon = PackedVector2Array([Vector2(-15,-8),Vector2(15,-8),Vector2(15,8),Vector2(-15,8)])
		platform.global_position = global_position + 20 * Vector2(cos(rotation),sin(rotation)).normalized()
		platform.linear_velocity = right_speed * Vector2(cos(rotation),sin(rotation)).normalized()
		if get_parent().mouse_position.x - global_position.x != 0:
			platform.rotation = rotation
		
		get_parent().get_parent().add_child(platform)
		
		right_speed = right_speed_default
