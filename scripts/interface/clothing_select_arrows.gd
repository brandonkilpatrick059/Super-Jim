extends Node2D

@onready var arrow_right : AnimatedSprite2D = $arrow_right
@onready var arrow_left : AnimatedSprite2D = $arrow_left

func set_active():
	arrow_left.play("active")
	arrow_right.play("active")

func set_inactive():
	arrow_left.play("inactive")
	arrow_right.play("inactive")

func set_off():
	arrow_left.play("off")
	arrow_right.play("off")
