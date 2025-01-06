extends RigidBody2D
#Ability as item form to be picked up by player. Unknown if will keep as non physical form, or if beocmes interactable later.
class_name Ability_item

var ability_name : String


func AbilityItem(ability_namee, global_positionn):
	ability_name = ability_namee
	global_position = global_positionn
	
	
	#get sprite of ability_name and paste it on friggin circle





# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
