extends Area2D
class_name Explosion

var age
var LIFETIME = 1 #number of seconds alive

func Explosion(scalee, global_positionn):
	scale = scalee
	global_position = global_positionn

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().my_ID == 1:
		connect("area_entered", area_entered)
		connect("body_entered", body_entered)
		age = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().my_ID == 1:
		if age > LIFETIME:
			queue_free()
		
		age += delta
		$Label.text = str(age)

func area_entered(area):
	pass
	
func body_entered(body):
	if body is Platform:
		if body.BREAKABLE:
			body.apply_impulse(2000000 * Vector2(body.position.x - position.x, body.position.y - position.y).normalized())
			body.temp += 1
			print("ran")
			##get_parent().delete_object(str(body), body)
	elif body is Player:
		body.velocity = 1800 * Vector2(body.position.x - position.x, body.position.y - position.y).normalized()
		body.toastedness += 1
		##body.die()
	elif body is Missle:
		#dunno if impulse even does anything since it explodes immediately
		body.apply_impulse(2000000 * Vector2(body.position.x - position.x, body.position.y - position.y).normalized())
		body.explode()
