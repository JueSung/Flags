extends RigidBody2D
class_name Platform

var IS_MELEE = false #its a projecitle

var BREAKABLE = true

var platform_data=  {}

var heat_sources = 0 #num of things that are heating up platform
var temp = 0 #incr in temp = heat sources per second
var TEMPTOLERANCE = 5
var on_fire = false
var objects_touching = []

var stacked_ability = {}

#constructors------------------------------------------------------------------------------------------
#constructor for ability instantiated platforms
func Ability(global_positionn, rotationn, stacked):
	Platform(48, 90, global_positionn + 24 * Vector2(cos(rotationn), sin(rotationn)).normalized(), rotationn, \
	60 * Vector2(cos(rotationn), sin(rotationn)).normalized(), true)

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
	platform_data["type"] = "platform"
	
	get_parent().objects[str(self)] = self
	get_parent().objects_data[str(self)] = platform_data
	
	if get_parent().my_ID == 1:
		$ExtendedRange.connect("body_entered", body_entered)
		$ExtendedRange.connect("body_exited", body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().my_ID == 1:
		temp += heat_sources * delta
		if temp > TEMPTOLERANCE and not on_fire:
			print("platfrom on fire")
			on_fire = true
			
			for body in objects_touching:
				body.add_heat_source()
			objects_touching = []
			
			
		platform_data["position"] = position
		platform_data["rotation"] = rotation

#non-melee aka projectile stuff---------------------------------------------------------------------
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
	ability.Ability(global_position + 24 * Vector2(cos(rotation), sin(rotation)).normalized(), rotation, true)
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

func lose_ability(stringified_ability):
	stacked_ability.erase(stringified_ability)

#------------------------------------------------------------------------------------------------

func get_data():
	return platform_data

func add_heat_source():
	heat_sources += 1
func remove_heat_source():
	heat_sources -= 1

func body_entered(body):
	if body is Player:
		if on_fire:
			body.add_heat_source()
		else:
			objects_touching.append(body)
func body_exited(body):
	if body is Player:
		if on_fire:
			body.remove_heat_source()
		else:
			if objects_touching.find(body) != -1:
				objects_touching.erase(body)

func update_data(platform_dataa):
	position = platform_dataa["position"]
	rotation = platform_dataa["rotation"]
