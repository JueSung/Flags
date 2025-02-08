extends RigidBody2D
class_name Missle

var IS_MELEE = false #its a projecitle
var speed = 0
var later_scale = 3.5 #related to scale
var free_soon = false
var collision_points = []

var raycasts

var age

var stacked_ability = {}
var objects_on_stack_chain = [] #lists objects part of stack chain so doesn't react with
var activated #explained in platform

var missle_data = {}

func Ability(global_positionn, rotationn, _stacked):
	global_position = global_positionn + 25 * Vector2(cos(rotationn), sin(rotationn)).normalized()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = get_parent().to_local(global_position)
	$CollisionShape2D.disabled = true
	$MissleA2D/CollisionShape2D.disabled = true
	$MissleA2D/RC1.enabled = false
	$MissleA2D/RC2.enabled = false
	$MissleA2D/RC3.enabled = false
	$MissleA2D/RC4.enabled = false
	hide()
	activated = false
	
	#multiplayer stuff
	#get_parent().objects[str(self)] = self
	#get_parent().objects_data[str(self)] = missle_data
	
	if get_tree().root.get_node("Main").my_ID == 1:
		objects_on_stack_chain.append(self)
		objects_on_stack_chain.append($MissleA2D)
		
		raycasts = [$MissleA2D/RC1, $MissleA2D/RC2, $MissleA2D/RC3, $MissleA2D/RC4]
		
		
		missle_data["type"] = "missle"
		missle_data["position"] = position
		
		contact_monitor = true
		max_contacts_reported = 20
		
		#connect("area_entered", area_entered)
		$MissleA2D.connect("body_entered", body_entered)
		$MissleA2D.connect("area_entered", area_entered)
		age = 0
	
	#$AnimationPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_tree().root.get_node("Main").my_ID == 1 and activated:
		missle_data = {}
		
		if free_soon:
			var temp = Vector2(0,0)
			var cc = 0
			for i in range(len(collision_points)):
				temp += collision_points[i]
				cc += 1
			global_position = temp / float(cc)
			explode()
		
		$MissleA2D/RC1.target_position.x = linear_velocity.length() * delta
		$MissleA2D/RC2.target_position.x = linear_velocity.length() * delta
		$MissleA2D/RC3.target_position.x = linear_velocity.length() * delta
		$MissleA2D/RC4.target_position.x = linear_velocity.length() * delta
		
		var rot = atan2(linear_velocity.y, linear_velocity.x) - rotation
		$MissleA2D/RC1.rotation = rot
		$MissleA2D/RC2.rotation = rot
		$MissleA2D/RC3.rotation = rot
		$MissleA2D/RC4.rotation = rot
		
		if $MissleA2D/RC1.is_colliding():
			if not $MissleA2D/RC1.get_collider() in objects_on_stack_chain:
				free_soon = true
				collision_points.append($MissleA2D/RC1.get_collision_point())
		if $MissleA2D/RC2.is_colliding():
			if not $MissleA2D/RC2.get_collider() in objects_on_stack_chain:
				free_soon = true
				collision_points.append($MissleA2D/RC2.get_collision_point())
		if $MissleA2D/RC3.is_colliding():
			if not $MissleA2D/RC3.get_collider() in objects_on_stack_chain:
				free_soon = true
				collision_points.append($MissleA2D/RC3.get_collision_point())
		if $MissleA2D/RC4.is_colliding():
			if not $MissleA2D/RC4.get_collider() in objects_on_stack_chain:
				free_soon = true
				collision_points.append($MissleA2D/RC4.get_collision_point())
		
		
		add_constant_central_force(1000000 * Vector2(cos(rotation), sin(rotation)).normalized())
		#position += velocity * delta
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
	#scale *= later_scale
	var explosion = preload("res://explosion.tscn").instantiate()
	explosion.Explosion(later_scale*scale, global_position)
	get_tree().root.get_node("Main").call_deferred("add_child", explosion) #add_child
	
	#multiplayer stuff
	#get_parent().delete_object(str(self), self)
	if objects_on_stack_chain.find(self) != -1:
		objects_on_stack_chain.remove_at(objects_on_stack_chain.find(self))
	queue_free()
		#missle_data["scale"] = scale
		#free_soon = true


func stack_ability(ability):
	if stacked_ability.size() != 0:
		for key in stacked_ability:
			#if projectile is present, there could only be one in stacked abilities
			if not stacked_ability[key].IS_MELEE:
				stacked_ability[key].stack_ability(ability)
				return
			else:
				if not ability.IS_MELEE:
					print("UH OH WE HAE PROBLEMA")
					break
	#only runs if stacked_ability.size() == 0 or only stacked ability(s) are melee. Then ability must be melee
	##ability.Ability(global_position + 25 * Vector2(cos(rotation), sin(rotation)).normalized(), rotation, true)
	ability.Ability(global_position + 25 * Vector2(cos(get_parent().rotation), sin(get_parent().rotation)).normalized(), get_parent().rotation, true)
	ability.objects_on_stack_chain = objects_on_stack_chain
	
	#rn have it so projectiles don't stick to each other, they just spawn there
	if not ability.IS_MELEE:
		get_parent().add_child(ability)
		stacked_ability[str(ability)] = ability
	else: #iS_MELEE
		add_child(ability)
		stacked_ability[str(ability)] = ability
		
		var count = 0
		for key in stacked_ability:
			stacked_ability[key].set_rotation_offset(int((count+1)/2) * PI/4.0 * (-1 * (-2 * (count % 2) + 1))\
			 - PI/8.0 * ((stacked_ability.size()+1) % 2))
			count += 1

func showw(): #DW THIS WORKS STACKED_ABILITY != OBJECTS_ON_STACK_CHAIN
	show()
	#just goes down stack list so must be called from top
	for key in stacked_ability:
		stacked_ability[key].showw()
func hidee():
	hide()
	#just goes down stack list so must be called from top
	for key in stacked_ability:
		stacked_ability[key].hidee()

func activate():
	$CollisionShape2D.disabled = false
	$MissleA2D/CollisionShape2D.disabled = false
	$MissleA2D/RC1.enabled = true
	$MissleA2D/RC2.enabled = true
	$MissleA2D/RC3.enabled = true
	$MissleA2D/RC4.enabled = true
	
	var gP = get_parent().to_global(position)
	var rot = get_parent().rotation + rotation
	var main = get_tree().root.get_node("Main")
	get_parent().remove_child(self)
	main.add_child(self)
	global_position = gP
	rotation = rot
	
	show()
	activated = true
	for key in stacked_ability:
		stacked_ability[key].activate()

#2 so it doesn't "fail" to override Node2D's get_rotation() function
func get_rotation2():
	if not activated:
		return get_parent().rotation
	else:
		return rotation

#melee stuff---------------------------------------------------------------------
func lose_ability(stringified_ability):
	stacked_ability.erase(stringified_ability)

#------------------------------------------------------------------------------------------------

#collision handled either by this, or by Raycast in _process(delta)
func area_entered(area):
	if area.get_parent() in objects_on_stack_chain:
		return
	if area.get_parent() is Missle and str(self) < str(area):
		explode()
		area.get_parent().explode()

	
func body_entered(body):
	if body in objects_on_stack_chain:
		return
	if body is Platform:
		explode()
	#elif body.get_parent() is Map:
	#	explode()
	elif body is Player:
		explode()
	elif body is Missle and str(self) < str(body):
		explode()
		body.explode()
	#laser takes care of missle-laser collision
	

func update_data(missle_dataa):
	for key in missle_data:
		match key:
			"position":
				position = missle_dataa[key]
			"scale":
				scale = missle_dataa[key]
