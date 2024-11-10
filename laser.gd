extends Area2D
class_name Laser
var velocity = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	print("pos", position)
	print("rot", rotation)
	print("colpos", get_node("CollisionPolygon2D").polygon)
	for i in range(len(get_node("CollisionPolygon2D").polygon)):
		print(to_global(get_node("CollisionPolygon2D").polygon[i]))



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
			p2.append(to_global(area_collision_node.polygon[i]))
		
		print("p1", p1)
		print("p2", p2)
		print("clip p1,p2 ",Geometry2D.clip_polygons(p1,p2))
		print("clip p2,p1 ",Geometry2D.clip_polygons(p2,p1))
		
		rotation = 0
		area.get_parent().rotation = 0
		
		get_node("CollisionPolygon2D").polygon = Geometry2D.clip_polygons(p1,p2)[0]
		print("HEEHOO", get_node("CollisionPolygon2D").polygon, ", ", global_position)
		global_position = Vector2(0,0)
		area_collision_node.polygon = Geometry2D.clip_polygons(p2,p1)[0]
		for i in range(len(get_node("CollisionPolygon2D").polygon)):
			get_node("CollisionPolygon2D").polygon[i] - global_position
		print("HEE", global_position)
		for i in range(len(area_collision_node.polygon)):
			area_collision_node.polygon[i] - area.get_parent().global_position
		if  (area.get_parent().extra_area_polygons2.find(area) == -1):
			area.get_parent().get_node("CollisionPolygon2D").polygon = area_collision_node.polygon
		else:
			area.get_parent().extra_polygons[area.get_parent().extra_area_polygons2.find(area)].polygon = area_collision_node.polygon
		velocity = Vector2(0,0)
		print(get_node("CollisionPolygon2D").polygon)
		print(rotation)
		print(position)
