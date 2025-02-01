extends RigidBody2D
#used to produce ability_items

var cooldown
var ability_item_scene = preload("res://Ability_item.tscn")
var ability_types = ["Platform", "Missle", "Laser"]

var data

func Ability_Spawner(global_positionn, rotationn):
	global_position = global_positionn
	rotation = rotationn # at rot = 0, drop upwards

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown = .5 #randf_range(8,10)
	
	if get_tree().root.get_node("Main").my_ID == 1:
		data = {
			"type" : "Ability_Spawner",
			"global_position" : global_position,
			"rotation" : rotation
			#will have animation frame and stuff
		}
		
		get_tree().root.get_node("Main").add_child2(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_tree().root.get_node("Main").my_ID == 1:
		cooldown -= delta
	
		if cooldown < 0:
			#create ability_item
			cooldown = 10 #randf_range(8,10)
			
			var ability_item = ability_item_scene.instantiate()
			ability_item.AbilityItem(ability_types[randi_range(0,2)], global_position + 50 * Vector2(cos(rotation - PI/2.0), sin(rotation - PI/2.0)))
			get_tree().root.get_node("Main").add_child(ability_item)
			
			#multiplayer stuff
			#update data here
			#put animation stuff later

func get_data():
	return data

func update_data(dataa):
	pass #will later have stuff with animation frames and stuff but not planned global_position or rotation to change, but if so, then add
		
	
