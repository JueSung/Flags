extends RigidBody2D
#Ability as item form to be picked up by player. Unknown if will keep as non physical form, or if beocmes interactable later.
class_name Ability_item

var ability_name : String

var data

func AbilityItem(ability_namee, global_positionn):
	ability_name = ability_namee
	global_position = global_positionn
	print(self)
	
	#get sprite of ability_name and paste it on friggin circle





# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().root.get_node("Main").my_ID == 1:
		data = {
			"type" : "Ability_item",
			"ability_name" : ability_name,
			"global_position" : global_position,
			"rotation" : rotation
			#add animation stuff
		}

		get_tree().root.get_node("Main").add_child2(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().root.get_node("Main").my_ID == 1:
	
	
	#multiplayer stuff:
		
		data["global_position"] = global_position
		data["rotation"] = rotation
			#add animation stuff
		

func die():
	#parent is main
	get_parent().delete_object(str(self), self)
	queue_free()

func get_data():
	return data
func update_data(dataa):
	global_position = dataa["global_position"]
	rotation = dataa["rotation"]
	#animation stuff later
