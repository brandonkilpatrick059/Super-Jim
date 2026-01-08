@tool

extends AnimatedSprite2D

@export var wait_offset : float = 0
@export var not_prunable = false

var play_default_offset_node = preload("res://entities/util/play_default_offset_node.tscn")

var timer : Timer = Timer.new()

var random = RandomNumberGenerator.new()

var is_playing : bool = false

#var pruned : bool = false

func play_default_animation():
	var animation_name = "default"
	play(animation_name)

func is_timer_stopped():
	return timer.is_stopped()

#func _enter_tree() -> void:
	#if(pruned):
		#pruned = false
		#handle_offset()

func handle_offset():
	timer.start(random.randf_range(0,wait_offset))
	var node = play_default_offset_node.instantiate()
	add_child(node)

#func _exit_tree() -> void:
	#pruned = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if(!not_prunable):
		add_to_group("prunable")
	timer.one_shot = true
	add_child(timer)
	if(wait_offset > 0):
		handle_offset()
	else:
		play_default_animation()
