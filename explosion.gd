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
	if area is Missle:
		area.explode()
	
func body_entered(body):
	if body is Platform:
		if body.BREAKABLE:
			pass
			get_parent().delete_object(str(body), body)
		body.temp += 1
	elif body is Player:
		body.die()
