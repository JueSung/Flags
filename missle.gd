extends Area2D
class_name Missle
var velocity = Vector2(0,0)
var later_scale = 0 #related to scale
var free_soon = false
var free_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().my_ID == 1:
		connect("area_entered", area_entered)
		connect("body_entered", body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	if free_soon:
		free_count += delta
		if free_count > .02:
			queue_free()

func explode():
	velocity = Vector2(0,0)
	scale *= later_scale
	free_soon = true

#currently does not work for theoretical have area2d node and collisionpolygon of platform
func area_entered(area):
	if area is Missle and str(self) < str(area):
		explode()
		area.velocity = Vector2(0,0)
		area.free_soon = true
		area.scale *= area.later_scale
	
	
func body_entered(body):
	if body is Platform:
		explode()
		body.queue_free()
	elif body.get_parent() is Map:
		explode()
	elif body is Player:
		explode()
		body.die()
	#laser takes care of missle-laser collision
	
