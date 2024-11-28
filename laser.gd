extends Area2D
class_name Laser
var velocity = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta



func area_entered(area):
	if area.get_parent() is Platform:
		var area_collision_node = null
		if  (area.get_parent().extra_area_polygons2.find(area) == -1):
			area_collision_node = area.get_node("CollisionPolygon2D")
		else:
			area_collision_node = area.get_parent().extra_polygons2[area.get_parent().extra_area_polygons2.find(area)]
		
		var p1 = []
		for i in range(len(get_node("CollisionPolygon2D").polygon)):
			p1.append(to_global(get_node("CollisionPolygon2D").polygon[i]))
		var p2 = []
		for i in range(len(area_collision_node.polygon)):
			p2.append(area.get_parent().to_global(area_collision_node.polygon[i]))
		#print("##", p2[0])
		
		print("p1", p1)
		print("p2", p2)
		print("clip p1,p2 ",Geometry2D.clip_polygons(p1,p2))
		print("clip p2,p1 ",Geometry2D.clip_polygons(p2,p1))
		get_tree().paused = true
		
		rotation = 0
		area.get_parent().rotation = 0
		
		var p3 = Geometry2D.clip_polygons(p1,p2)[0]
		#global_position = Vector2(0,0)
		var p4 = Geometry2D.clip_polygons(p2,p1)[0]
		for i in range(len(get_node("CollisionPolygon2D").polygon)):
			get_node("CollisionPolygon2D").polygon[i] = to_local(p3[i])
		#if laser is has less than 3 verticies, delete bc no longer a 2d shape.
		if len(get_node("CollisionPolygon2D").polygon) < 3:
			queue_free()
		#---------
		
		for i in range(len(area_collision_node.polygon)):
			area_collision_node.polygon[i] = area.get_parent().to_local(p4[i])
			area.get_parent().extra_polygons[area.get_parent().extra_area_polygons2.find(area)].polygon = area_collision_node.polygon
		#if platform has less than 3 verticies, delete bc no longer a 2d shape
		if len(area_collision_node.polygon) < 3:
			print("EYO")
		
		#velocity = Vector2(0,0)
		#print("##",area_collision_node.polygon[0])
