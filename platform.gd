extends RigidBody2D
class_name Platform

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
	if body.get_parent() is Platform:
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
				var rot = atan2(body.get_node("CollisionPolygon2D").polygon[i].y, get_node("CollisionPolygon2D").polygon[i].x)
				var mag = sqrt(body.get_node("CollisionPolygon2D").polygon[i].x ** 2 + body.get_node("CollisionPolygon2D").polygon[i].y ** 2)
				p2.append(mag * Vector2(cos(rot + body.get_parent().rotation),sin(rot+body.get_parent().rotation)) + body.get_parent().global_position)
			
			var combined_points = p1 + p2#Geometry2D.convex_hull(p1 + p2)
			
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

