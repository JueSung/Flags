extends RigidBody2D
class_name Platform

var extra_polygons = [] #collisionpolygons of platform
var extra_polygons2 = [] #collisionpolygons of area2d
var extra_area_polygons2 = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().my_ID == 1:
		$Area2D.connect("area_entered", on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#self is node platform
#body is node area2d of platform
func on_area_entered(body):
	if body.get_parent() is Platform and body.get_parent() != self:
		print("body entered ::", self,"::", body.get_parent())
		if str(self) > str(body.get_parent()):
			#convert collisionpolygon verticies to global verticies

			var p1 = []
			for i in range(len(get_node("CollisionPolygon2D").polygon)):
				var rot = atan2(get_node("CollisionPolygon2D").polygon[i].y, get_node("CollisionPolygon2D").polygon[i].x)
				var mag = sqrt(get_node("CollisionPolygon2D").polygon[i].x ** 2 + get_node("CollisionPolygon2D").polygon[i].y ** 2)
				p1.append(mag * Vector2(cos(rot + rotation),sin(rot + rotation)) + global_position)
			var p2 = []
			for i in range(len(body.get_node("CollisionPolygon2D").polygon)):
				var rot = atan2(body.get_node("CollisionPolygon2D").polygon[i].y, body.get_node("CollisionPolygon2D").polygon[i].x)
				var mag = sqrt(body.get_node("CollisionPolygon2D").polygon[i].x ** 2 + body.get_node("CollisionPolygon2D").polygon[i].y ** 2)
				p2.append(mag * Vector2(cos(rot + body.get_parent().rotation),sin(rot+body.get_parent().rotation)) + body.get_parent().global_position)

			var p1_extras = []
			for i in range(len(extra_polygons)):
				p1_extras.append([])
				for j in range(len(extra_polygons[i].polygon)):
					var rot = atan2(extra_polygons[i].polygon[j].y, extra_polygons[i].polygon[j].x)
					var mag = sqrt(extra_polygons[i].polygon[j].x ** 2 + extra_polygons[i].polygon[j].y ** 2)
					p1_extras[i].append(mag * Vector2(cos(rot + rotation),sin(rot + rotation)) + global_position)
			var p2_extras = []
			for i in range(len(body.get_parent().extra_polygons)):
				p2_extras.append([])
				for j in range(len(body.get_parent().extra_polygons[i].polygon)):
					var rot = atan2(body.get_parent().extra_polygons[i].polygon[j].y, body.get_parent().extra_polygons[i].polygon[j].x)
					var mag = sqrt(body.get_parent().extra_polygons[i].polygon[j].x ** 2 + body.get_parent().extra_polygons[i].polygon[j].y ** 2)
					p2_extras[i].append(mag * Vector2(cos(rot + body.get_parent().rotation),sin(rot+body.get_parent().rotation))+body.get_parent().global_position)
			
			#p1, p2 global verticies
			
			#get average point of x y values of all verticies for new center
			var average_position = Vector2(0,0)
			var count = 0
			for i in range(len(p1)):
				average_position.x += p1[i].x
				average_position.y += p1[i].y
				count += 1
			for i in range(len(p2)):
				average_position.x += p1[i].x
				average_position.y += p2[i].y
				count += 1
			for i in range(len(p1_extras)):
				for j in range(len(p1_extras[i])):
					average_position.x += p1_extras[i][j].x
					average_position.y += p1_extras[i][j].y
					count += 1
			for i in range(len(p2_extras)):
				for j in range(len(p2_extras[i])):
					average_position.x += p2_extras[i][j].x
					average_position.y += p2_extras[i][j].y
					count += 1
			average_position /= count

			global_position = average_position
			
			#convert to local coords with new rotation 0
			for i in range(len(p1)):
				p1[i] -= global_position
			for i in range(len(p2)):
				p2[i] -= global_position
			for i in range(len(p1_extras)):
				for j in range(len(p1_extras[i])):
					p1_extras[i][j] -= global_position
			for i in range(len(p2_extras)):
				for j in range(len(p2_extras[i])):
					p2_extras[i][j] -= global_position
			
			body.get_parent().call_deferred("free")
			
			
			rotation = 0
			get_node("CollisionPolygon2D").polygon = p1
			get_node("Area2D/CollisionPolygon2D").polygon = p1
			
			for i in range(len(extra_polygons)):
				extra_polygons[i].polygon = p1_extras[i]
				extra_polygons2[i].polygon = p1_extras[i]
			
			var instance = CollisionPolygon2D.new()
			instance.polygon = p2
			add_child(instance)
			extra_polygons.append(instance)
			
			instance = CollisionPolygon2D.new()
			instance.polygon = p2
			var area_instance = Area2D.new()
			area_instance.add_child(instance)
			add_child(area_instance)
			extra_polygons2.append(instance)
			extra_area_polygons2.append(area_instance)
			print('ran')
			
			for i in range(len(p2_extras)):
				instance = CollisionPolygon2D.new()
				instance.polygon = p2_extras[i]
				add_child(instance)
				extra_polygons.append(instance)
				
				instance = CollisionPolygon2D.new()
				instance.polygon = p2_extras[i]
				area_instance = Area2D.new()
				area_instance.add_child(instance)
				add_child(area_instance)
				extra_polygons2.append(instance)
				extra_area_polygons2.append(area_instance)
			
			print("---------------")
			#linear_velocity = Vector2(0,0)
			#angular_velocity = 0
			
			
			
			
			
func set_value(thing, value):
	thing = value
			
			#save for calculating lasers
"""
			var intersection_points = []
			intersection_points = get_intersection_points(p1,p2)
			print("intersection_points, ", intersection_points)
			var combined_points = construct_polygon(p1, p2, intersection_points) #Geometry2D.convex_hull(p1 + p2)
			
			print(p1, "::", p2)
			print(combined_points)
			
			#var instance = preload("res://Platform.tscn").instantiate()
			#instance.get_node("CollisionPolygon2D").polygon = combined_points
			#instance.get_node("Area2D").get_node("CollisionPolygon2D").polygon = combined_points
			#get_parent().add_child(instance)
			#instance.position = Vector2(0,0)
			
			#convert combined_points to relative verticies of platform
			for i in range(len(combined_points)):
				combined_points[i] = combined_points[i] - global_position
			body.get_parent().queue_free()
			
			call_deferred("on_area_entered")
			get_node("CollisionPolygon2D").polygon = combined_points
			rotation = 0
			get_node("Area2D").get_node("CollisionPolygon2D").polygon = combined_points
			print("EEE")
			for i in range(len(get_node("CollisionPolygon2D").polygon)):
				print(get_node("CollisionPolygon2D").polygon[i] + global_position)

func construct_polygon(p1, p2, intersection_points):
	#find what verticies of p1 is in p2 and the converse
	var p1_new = []
	var prev_inside = true
	for i in range(len(p1)):
		var pt_inside = point_inside_polygon(p1[i], p2)
		if not pt_inside:
			if prev_inside:
				p1_new.append([])
			p1_new[len(p1_new)-1].append(p1[i])
		prev_inside = pt_inside
	print("p1:", p1_new)
	
	var p2_new = []
	prev_inside = true
	for i in range(len(p2)):
		var pt_inside = point_inside_polygon(p2[i], p1)
		if not pt_inside:
			if prev_inside:
				p2_new.append([])
			p2_new[len(p2_new)-1].append(p2[i])
		prev_inside = pt_inside
	print("p2:", p2_new)
	
	
	var combined_points = []
	
	
	
	
	return combined_points

#point is a Vector2 coords, polygon is list of verticies
func point_inside_polygon(point, polygon):
	var inside = false
	#if horizontal vector from point crosses polygon border odd num of times, point is inside polygon
	for i in range(len(polygon)):
		var j = (i+1) % len(polygon)
		if ((polygon[i].y > point.y) != (polygon[j].y > point.y)) and \
		(point.x < (polygon[j].x -polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x):
			inside = not inside
	return inside
		



#p1,p2 are lists of verticies that describe overlapping polygons
func get_intersection_points(p1,p2):
	var intersected_points = [] #list of vector2
	for i in range(len(p1)):
		var v11 = p1[i]
		var v12 = p1[(i+1)%len(p1)]
		var y1diff = v12.y - v11.y
		var x1diff = v11.x - v12.x
		var b1 = y1diff * v11.x + x1diff * v11.y
		for j in range(len(p2)):
			var v21 = p2[j]
			var v22 = p2[(j+1)%len(p2)]
			var y2diff = v22.y - v21.y
			var x2diff = v21.x - v22.x
			var b2 = y2diff * v21.x + x2diff * v21.y
			
			var determinant = y1diff * x2diff - x1diff * y2diff
			if abs(determinant) < 0.000001: #parallelogram collapse into lower dimension, are linear combinations, zero, or infinite intersection
				continue
			var x = (b1 * x2diff - b2 * x1diff) / determinant
			var y = (y1diff * b2 - y2diff * b1) / determinant
			
			#check if intersection points are within range
			if x >= min(v11.x, v12.x) and x <= max(v11.x,v12.x) and x >= min(v21.x, v22.x) and x <= max(v21.x, v22.x):
				if y >= min(v11.y, v12.y) and y <= max(v11.y,v12.y) and y >= min(v21.y, v22.y) and y <= max(v21.y, v22.y):
					if Vector2(x,y) not in intersected_points:
						intersected_points.append(Vector2(x,y))
	return intersected_points
	"""
