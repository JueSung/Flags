extends RigidBody2D
class_name Platform

var IS_MELEE = false #its a projecitle

var BREAKABLE = true

var platform_data=  {}

var heat_sources = 0 #num of things that are heating up platform
var temp = 0 #incr in temp = heat sources per second

#tolerance for on fire
var TEMPTOLERANCE = 10
var on_fire = false
#tolerance for platform destruction
var TEMPTOLERANCE2 = 20

var objects_touching = []

var stacked_ability = {}
var objects_on_stack_chain = [] #lists objects part of stack chain so doesn't react with

#not  activated until activate() is called aka when ability is fired used for showing mouse button held\
#down ability without firing and pre-instantiating abilities
var activated = true

var stringified_reference = ""

#constructors------------------------------------------------------------------------------------------
#constructor for ability instantiated platforms
func Ability(global_positionn, rotationn, stacked):
	Platform(48, 90, global_positionn + 24 * Vector2(cos(rotationn), sin(rotationn)).normalized(), 0, \
	60 * Vector2(cos(rotationn), sin(rotationn)).normalized(), true)
	activated = false
	
func assign_stringified_reference(stringified_referencee):
	stringified_reference = stringified_referencee

#general constructor
func Platform(x,y,pos,rot,linear_v, breakable):
	$CollisionPolygon2D.polygon = PackedVector2Array([Vector2(-1*x/2,-1*y/2),Vector2(x/2,-1*y/2),Vector2(x/2,y/2),Vector2(-1*x/2,y/2)])
	$ExtendedRange/CollisionPolygon2D.polygon = PackedVector2Array([Vector2(-1*x/2-30, -1 * y/2-30), Vector2(x/2+30, -1*y/2-30), Vector2(x/2+30, y/2+30), Vector2(-1*x/2-30, y/2+30)])
	global_position = pos
	rotation = rot
	linear_velocity = linear_v
	BREAKABLE = breakable
	mass = x * y
	
	platform_data["x"] = x
	platform_data["y"] = y
	platform_data["position"] = pos
	platform_data["rotation"] = rot
	
	$Sprite2D.scale = Vector2(0.023 * x/30, .024 * y/16)

#------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	#start deactivated if constructor Ability() is run -- activatd by activate() function
	if activated == false:
		global_position = get_parent().to_local(global_position)
		$CollisionPolygon2D.disabled = true
		$ExtendedRange/CollisionPolygon2D.disabled = true
		hide()
	#---------
	
	
	platform_data["type"] = "platform"
	#multiplayer stuff
	#get_parent().objects[str(self)] = self
	#get_parent().objects_data[str(self)] = platform_data
	
	if get_tree().root.get_node("Main").my_ID == 1:
		objects_on_stack_chain.append(self)
		objects_on_stack_chain.append($ExtendedRange)
		
		$ExtendedRange.connect("body_entered", body_entered)
		$ExtendedRange.connect("body_exited", body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().root.get_node("Main").my_ID == 1 and activated:
		temp += heat_sources * delta
		$Label.text = str(temp)
		if temp > TEMPTOLERANCE and not on_fire:
			print("platfrom on fire")
			on_fire = true
			heat_sources += 1
			
			for i in range(len(objects_touching)):
				objects_touching[i].add_heat_source()
			##objects_touching = []
		#dies - on fire for too long
		if temp > TEMPTOLERANCE2:
				die()
			
		platform_data["position"] = position
		platform_data["rotation"] = rotation

func die():
	#assuming already on fire
	for i in range(len(objects_touching)):
		if objects_touching[i] != null:
			objects_touching[i].remove_heat_source()
	
	queue_free()

func stack_ability(ability):
	if stacked_ability.size() != 0:
		for key in stacked_ability:
			#if projectile is present, there could only be one in stacked abilities
			if not stacked_ability[key].IS_MELEE:
				stacked_ability[key].stack_ability(ability)
				return
			else:
				break
	#only runs if stacked_ability.size() == 0 or only stacked ability(s) are melee. Then ability must be melee
	##ability.Ability(global_position + 24 * Vector2(cos(rotation), sin(rotation)).normalized(), rotation, true)
	ability.Ability(global_position + 24 * Vector2(cos(get_parent().rotation), sin(get_parent().rotation)).normalized(), get_parent().rotation, true)
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

func showw():
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
	$CollisionPolygon2D.disabled = false
	$ExtendedRange/CollisionPolygon2D.disabled = false
	show()
	var gP = get_parent().to_global(position)
	var rot = get_parent().rotation + rotation
	var main = get_tree().root.get_node("Main")
	get_parent().remove_child(self)
	main.add_child(self)
	global_position = gP
	rotation = rot
	linear_velocity = 180 * Vector2(cos(rotation), sin(rotation)).normalized()
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

func get_data():
	return platform_data

func add_heat_source():
	if BREAKABLE:
		heat_sources += 1
func remove_heat_source():
	if heat_sources > 0:
		heat_sources -= 1

func body_entered(body):
	if body is Player || body is Platform:
		if on_fire:
			body.add_heat_source()
		else:
			objects_touching.append(body)
func body_exited(body):
	if body is Player || body is Platform:
		if on_fire:
			body.remove_heat_source()
		else:
			if objects_touching.find(body) != -1:
				objects_touching.erase(body)

func update_data(platform_dataa):
	position = platform_dataa["position"]
	rotation = platform_dataa["rotation"]
