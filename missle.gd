extends Area2D
class_name Missle
var velocity = Vector2(0,0)
var max_speed = 1800
var speed = 0
var later_scale = 3.5 #related to scale
var free_soon = false
var collision_point = null

var age

var missle_data = {}

func Ability(global_positionn, rotationn):
	#max velocity also contains info about direction
	global_position = global_positionn
	rotation = rotationn

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().objects[str(self)] = self
	get_parent().objects_data[str(self)] = missle_data
	
	if get_parent().my_ID == 1:
		
		
		
		missle_data["type"] = "missle"
		missle_data["position"] = position
		
		"""connect("area_entered", area_entered)
		connect("body_entered", body_entered)"""
		age = 0
		velocity = Vector2(0,0)
	
	$AnimationPlayer.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().my_ID == 1:
		missle_data = {}
		
		if free_soon:
			global_position = collision_point
			explode()
		
		if age > 3 or speed >= max_speed:
			speed = max_speed * 3
			
			age = -500000
		elif age >= 1:
			speed += max_speed * .1
		elif age >= 0:
			speed += max_speed * .05
		
		velocity = speed * Vector2(cos(rotation), sin(rotation)).normalized()
		
		#50 is length of collision shape of missle
		$RayCast2D.target_position.x = velocity.length() * delta
		$RayCast2D2.target_position.x = velocity.length() * delta
		if $RayCast2D.is_colliding():
			free_soon = true
			collision_point = $RayCast2D.get_collision_point()
		if $RayCast2D2.is_colliding():
			free_soon = true
			if collision_point != null:
				collision_point = (collision_point + $RayCast2D2.get_collision_point())/2.0
			else:
				collision_point = $RayCast2D2.get_collision_point()
		
		
		position += velocity * delta
		age += delta
		#if free_soon:
		#	free_count += delta
		#	if free_count > .04:
		#		get_parent().delete_object(str(self), self)
		
		missle_data["position"] = position

func get_data():
	return missle_data

func explode():
	#if not free_soon:
	velocity = Vector2(0,0)
	#scale *= later_scale
	var explosion = preload("res://explosion.tscn").instantiate()
	explosion.Explosion(later_scale*scale, global_position)
	get_parent().add_child(explosion)
	
	get_parent().delete_object(str(self), self)
	queue_free()
		#missle_data["scale"] = scale
		#free_soon = true

#collision handled either by this, or by Raycast in _process(delta)
func area_entered(area):
	if area is Missle and str(self) < str(area):
		explode()
		area.explode()
	
	
func body_entered(body):
	if body is Platform:
		explode()
		#if body.BREAKABLE:
			#get_parent().delete_object(str(body), body)
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
