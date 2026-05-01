extends Node2D

var animated_sprite : AnimatedSprite2D

var food_left = 4

func _ready() -> void:
	animated_sprite = get_parent().find_child("sprite")

func show_food_left():
	if(food_left <= 0):
		get_parent().queue_free()
	else:
		animated_sprite.play(str(food_left))

func is_picked_up():
	return get_parent().is_picked_up()

func reduce_food():
	food_left = food_left - 1
	show_food_left()
