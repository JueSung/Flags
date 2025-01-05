extends Node2D
#rope segments need to be scaled likely
var segment_length = 16.0 #pixels

var segment_objects = []

#down is 0 for rope segments

# Called when the node enters the scene tree for the first time.
func _ready():
	#start end_point
	$Rope_End.position = Vector2(100,100)
	$Rope_End2.position = Vector2(800,800)
	
	var num = int(700.0 * sqrt(2) / segment_length)
	var next_parent = $Rope_End
	for i in range(num):
		var segment = preload("res://rope_segment.tscn").instantiate()
		segment.rotation = -45 #cant do math
		segment.position = Vector2(100 + i * segment_length * sqrt(2)/2.0, 100 + i * segment_length * sqrt(2)/2.0)
		
		add_child(segment)
		segment.get_node("C/P").node_a = segment.get_path()
		
		if i == 0:
			segment.global_position = $Rope_End.get_node("C/P").global_position
		else:
			segment.global_position = segment_objects[i-1].get_node("C/P").global_position
			segment_objects[-1].get_node("C/P").node_b = segment.get_path()
			
		segment_objects.append(segment)
	$Rope_End.get_node("C/P").node_b = segment_objects[0].get_path()
	$Rope_End2.position = segment_objects[-1].get_node("C/P").global_position
	$Rope_End2.get_node("C/P").node_b = segment_objects[-1].get_path()
	segment_objects[-1].get_node("C/P").node_b = $Rope_End2.get_path()
	
	
	$Rope_End2.freeze = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#for i in range(len(segment_objects)):
		#if i == 0:
		#	segment_objects[i].rotation = atan2(segment_objects[i].position.y - $Rope_End.position.y, segment_objects[i].position.x - $Rope_End.position.x)
		#elif i != len(segment_objects)-1:
		#	segment_objects[i].rotation = -PI/2.0 + atan2(segment_objects[i+1].position.y - (segment_objects[i].position.y - 32.0 * cos(segment_objects[i].rotation)), segment_objects[i+1].position.x - (segment_objects[i].position.x+32.0 * sin(segment_objects[i].rotation)))
		#else:
		#	segment_objects[i].rotation = PI/2.0 + atan2($Rope_End2.position.y - (segment_objects[i].position.y - 32.0 * cos(segment_objects[i].rotation)), $Rope_End2.position.x - (segment_objects[i].position.x + 32.0 * sin(segment_objects[i].rotation)))
		#segment_objects[i].rotation = 0
		#segment_objects[i].freeze = false
		#segment_objects[i].get_node("C").disabled = false
			
	
