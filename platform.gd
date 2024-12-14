extends RigidBody2D
class_name Platform

var heat_sources = 0 #num of things that are heating up platform
var temp = 0 #incr in temp = heat sources per second
var TEMPTOLERANCE = 5
var on_fire = false

#constructor
func Platform(x,y,pos,rot,linear_v):
	$CollisionPolygon2D.polygon = PackedVector2Array([Vector2(-1*x/2,-1*y/2),Vector2(x/2,-1*y/2),Vector2(x/2,y/2),Vector2(-1*x/2,y/2)])
	$Extended_Range/CollisionPolygon2D.polygon = PackedVector2Array([Vector2(-1*x/2-10, -1 * y/2-10), Vector2(x/2+10, -1*y/2-10), Vector2(x/2+10, y/2+10), Vector2(-1*x/2-10, y/2+10)])
	global_position = pos
	rotation = rot
	linear_velocity = linear_v
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().my_ID == 1:
		pass
		print($CollisionPolygon2D)
		get_node("Extended_Range").connect("body_entered", body_entered)
		get_node("Extended_range").connect("body_exited", body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().my_ID == 1:
		temp += heat_sources * delta
		if temp > TEMPTOLERANCE and not on_fire:
			on_fire = true

func add_heat_source():
	heat_sources += 1
func remove_heat_source():
	heat_sources -= 1

func body_entered(body):
	if body is Player:
		if on_fire:
			body.add_heat_source()
func body_exited(body):
	if body is Player:
		if on_fire:
			body.remove_heat_source()
