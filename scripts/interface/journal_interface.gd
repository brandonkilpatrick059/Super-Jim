extends Node2D

@onready var frame = $frame

var timer := Timer.new()
var timer_step : float = 0.006

var rising : bool = false
var lowering : bool = false
var closing : bool = false
var opening : bool = false
var is_open : bool = false

var move_speed: float = 32.0


func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func open():
	frame.play("closed")
	opening = true
	rising = true

func close():
	frame.play("close")
	opening = false
	rising = false
	closing = true
	is_open = false

func handle_opening():
	if(rising):
		if(frame.position.y > 0):
			frame.position = frame.position + Vector2(0,-move_speed)
		else:
			frame.position = Vector2(0,0)
			rising = false
			frame.play("open")
	if(!rising):
		if(frame.frame == 2):
			frame.play("opened")
			is_open = true
			opening = false

func handle_closing():
	if(lowering):
		if(frame.position.y < 512):
			frame.position = frame.position + Vector2(0,move_speed)
		else:
			frame.position = Vector2(0,512)
			lowering = false
			frame.play("close")
			var time_keeper = get_tree().get_first_node_in_group("time_keeper")
			time_keeper.unpause_parent_tree()
			queue_free()
	if(!lowering):
		if(frame.frame == 2):
			frame.play("closed")
			is_open = false
			lowering = true

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		if(Input.is_action_just_pressed("journal")):
			if(is_open):
				close()
		if(opening):
			handle_opening()
		if(closing):
			handle_closing()
		timer.start(timer_step)
