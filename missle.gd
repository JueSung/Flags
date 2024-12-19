extends Area2D
class_name Missle
var velocity = Vector2(0,0)
var later_scale = 0 #related to scale
var free_soon = false
var free_count = 0

var missle_data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().objects[str(self)] = self
	get_parent().objects_data[str(self)] = missle_data
	
	if get_parent().my_ID == 1:
		missle_data["type"] = "missle"
		missle_data["position"] = position
		
		connect("area_entered", area_entered)
		connect("body_entered", body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	missle_data = {}
	position += velocity * delta
	if free_soon:
		free_count += delta
		if free_count > .04:
			get_parent().delete_object(str(self), self)
	
	missle_data["position"] = position

func get_data():
	return missle_data

func explode():
	if not free_soon:
		velocity = Vector2(0,0)
		scale *= later_scale
		missle_data["scale"] = scale
		free_soon = true

#currently does not work for theoretical have area2d node and collisionpolygon of platform
func area_entered(area):
	if area is Missle and str(self) < str(area):
		explode()
		area.explode()
	
	
func body_entered(body):
	if body is Platform:
		explode()
		if body.BREAKABLE:
			get_parent().delete_object(str(body), body)
	elif body.get_parent() is Map:
		explode()
	elif body is Player:
		explode()
		body.die()
	#laser takes care of missle-laser collision
	

func update_data(missle_dataa):
	for key in missle_data:
		match key:
			"position":
				position = missle_dataa[key]
			"scale":
				scale = missle_dataa[key]
