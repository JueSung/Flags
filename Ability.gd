#this is an outline, not a script meant to be run
extends RigidBody2D #or Area2D

var activated
var objects_on_stack_chain = []

#for projectiles:
var stacked_ability = {}


#not real attributes
var horizontal_distance_from_center

func Ability(global_positionn, rotationn, stacked):
	#projectiles
	global_position = global_positionn + horizontal_distance_from_center * \
	Vector2(cos(rotationn), sin(rotationn)).normalized()

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = get_parent().to_local(global_position)
	#disable all collision_nodes and hitboxes
	hide()
	activated = false
	
	if get_tree().root.get_node("Main").my_ID == 1:
		#this works because the object is added to the scene and _ready runs either
		#a) when being added to weapon of player and is child of weapon and thus only needs itself to be stacked on
		#b) when being stacked on a projectile of which it is first assigned the reference to the communal array and THEN
		#   is added to scene and adds itself to the list.
		objects_on_stack_chain.append(self)
		#add any other child area2d nodes or anything that shouldn't be blown up by other stacked abilities


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass






#note - stacked_ability is not objects_on_stack_chain
#starts at "root" node and moves down through stacked_abilities and then those abilities will send to their stacked_abilities
#so there isn't going to be a loop issue
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

