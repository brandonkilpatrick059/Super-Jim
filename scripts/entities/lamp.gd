extends StaticBody2D

@onready var point_light : PointLight2D = $PointLight2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

var active = true

func ready():
	active =  true
	if(active):
		point_light.enabled = true
		animated_sprite.play("active")
	else:
		point_light.enabled = false
		animated_sprite.play("inactive")

func interact():
	active = !active
	if(active):
		point_light.enabled = true
		animated_sprite.play("active")
	else:
		point_light.enabled = false
		animated_sprite.play("inactive")
	var fx_player = get_tree().get_first_node_in_group("main_fx_player")
	fx_player.stream = load("res://audio/soundFX/click_2.ogg")
	fx_player.play()
