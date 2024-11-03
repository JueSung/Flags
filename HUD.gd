extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Host_Game.visible = true
	$Join_Game.visible = true
	$Start_Game.visible = false
	$Back_to_title.visible = false

#host_game button connected to main host_game(), which calls HUD host_game()
func host_game():
	$Host_Game.visible = false
	$Join_Game.visible = false
	$Start_Game.visible = true
	$Back_to_title.visible = true

#join_game button connected to main join_game(), which calls HUD join_game()
func join_game():
	$Host_Game.visible = false
	$Join_Game.visible = false
	$Back_to_title.visible = true

func back_to_title():
	$Host_Game.visible = true
	$Join_Game.visible = true
	$Start_Game.visible = false
	$Back_to_title.visible = false
