extends Node2D
class_name Map
var map #integer corresponding to what map it is

var platform_scene = preload("res://platform.tscn")


func Map(m):
	map = m

# Called when the node enters the scene tree for the first time.
func _ready():
	if map == 1:
		make_platform(60,1080,Vector2(0,525),0,Vector2(0,0), false)
		make_platform(1920,30,Vector2(960,1080), 0, Vector2(0,0), false)
		make_platform(60,1080,Vector2(1920,525),0,Vector2(0,0), false)
		
		var ability_spawner = preload("res://ability_spawner.tscn").instantiate()
		ability_spawner.Ability_Spawner(Vector2(400,400), PI/2.0)
		get_tree().root.get_node("Main").add_child(ability_spawner)
		
		var ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Missle", Vector2(400, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Missle", Vector2(400, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Missle", Vector2(400, 100))
		get_parent().add_child(ability_item)
		
		"""
		for i in range(12):
			ability_item = preload("res://ability_item.tscn").instantiate()
			ability_item.AbilityItem("Laser", Vector2(400, 100))
			get_parent().add_child(ability_item)
		for i in range(12):
			ability_item = preload("res://ability_item.tscn").instantiate()
			ability_item.AbilityItem("Missle", Vector2(400, 100))
			get_parent().add_child(ability_item)
		"""
		
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Platform", Vector2(1200, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Platform", Vector2(1200, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Platform", Vector2(1200, 100))
		get_parent().add_child(ability_item)


		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)
		ability_item = preload("res://ability_item.tscn").instantiate()
		ability_item.AbilityItem("Laser", Vector2(800, 100))
		get_parent().add_child(ability_item)

func make_platform(x,y,pos,rot,linear_velocity, breakable):
	var p = platform_scene.instantiate()
	p.Platform(x,y,pos,rot,linear_velocity, breakable)
	p.freeze = true
	get_parent().add_child(p)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
