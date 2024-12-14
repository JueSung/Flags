extends Area2D
class_name Missle
var velocity = Vector2(0,0)
var later_scale = 0 #related to scale
var free_soon = false
var free_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	if free_soon:
		free_count += delta
		if free_count > .02:
			queue_free()



#currently does not work for theoretical have area2d node and collisionpolygon of platform
func area_entered(area):
	if area is Missle and str(self) < str(area):
		velocity = Vector2(0,0)
		free_soon = true
		scale *= later_scale
		area.velocity = Vector2(0,0)
		area.free_soon = true
		area.scale *= area.later_scale
	
	
func body_entered(body):
	if body is Platform:
		velocity = Vector2(0,0)
		free_soon = true
		scale *= later_scale
		body.queue_free()
	elif body.get_parent() is Map:
		velocity = Vector2(0,0)
		free_soon = true
		scale *= later_scale
	elif body is Player:
		velocity = Vector2(0,0)
		free_soon = true
		scale *= later_scale
		body.die()
	#laser takes care of missle-laser collision
	
	
	
	
	
	
	
	
	
	#---attempt with singular platform things and missle (used to be called "laser") as rectangle as area2d with collisionpolygon2d - fail
	"""var collision_node = null #corresponds to area's collision node
	if area.get_parent() is Platform or area is Laser:
		collision_node = area.get_node("CollisionPolygon2D")
		var p1 = []
		for i in range(len(get_node("CollisionPolygon2D").polygon)):
			p1.append(to_global(get_node("CollisionPolygon2D").polygon[i]))
		var p2 = []
		if area is Laser:
			for i in range(len(collision_node.polygon)):
				p2.append(area.to_global(collision_node.polygon[i]))
		else: #area.get_parent() is Platform
			for i in range(len(collision_node.polygon)):
				p2.append(area.get_parent().to_global(collision_node.polygon[i]))
			
		rotation = 0
		
		print("p1: ", p1)
		print("p2: ", p2)
		
		var p3 = Geometry2D.clip_polygons(p1,p2)
		print("p3: ",p3)
		#global_position = Vector2(0,0)
		for i in range(len(p3)):
			if i == 0:
				if len(p3[0]) >=3:
					for j in range(len(p3[0])):
						p3[0][j] = to_local(p3[0][j])
					get_node("CollisionPolygon2D").polygon = p3[0]
				else:
					queue_free()
			else:
				if len(p3[i]) >= 3:
					var instance = preload("laser.tscn").instantiate()
					for j in range(len(p3[i])):
						p3[i][j] = instance.to_local(p3[i][j])
					instance.get_node("CollisionPolygon2D").polygon = p3[i]
					instance.velocity = velocity
					get_parent().add_child(instance)
				
		if area is Laser:
			area.rotation = 0
		else:
			area.get_parent().rotation = 0
		
		var p4 = Geometry2D.clip_polygons(p2,p1)
		print(p4)
		for i in range(len(p4)):
			if i == 0:
				if len(p4[0]) >= 3:
					for j in range(len(p4[0])):
						if area is Laser:
							p4[0][j] = area.to_local(p4[0][j])
						else:
							p4[0][j] = area.get_parent().to_local(p4[0][j])
					collision_node.polygon = p4[0]
					if area.get_parent() is Platform:
						area.get_parent().get_node("CollisionPolygon2D").polygon = p4[0]
				else:
					if area.get_parent() is Platform:
						area.get_parent().queue_free()
					else: #is laser
						area.queue_free()
			else:
				if len(p4[i]) >= 3:
					var instance = null
					var instance_collision_node = []
					if area is Laser:
						instance = preload("Laser.tscn").instantiate()
						instance.position = area.position
						instance_collision_node = [instance.get_node("CollisionPolygon2D")]
					else: #is Platform
						instance = preload("Platform.tscn").instantiate()
						instance.position = area.get_parent().position
						instance_collision_node = [instance.get_node("Area2D").get_node("CollisionPolygon2D"), instance.get_node("CollisionPolygon2D")]
					for j in range(len(p4[i])):
						p4[i][j] = instance.to_local(p4[i][j])
					for j in range(len(instance_collision_node)):
						instance_collision_node[j].polygon = p4[i]
					get_parent().add_child(instance)
		#get_tree().paused = true
		"""
		
		
		#------------------------------------
		
	"""
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
		"""
