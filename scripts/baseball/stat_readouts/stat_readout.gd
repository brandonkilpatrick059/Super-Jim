@tool
class_name StatReadout
extends Node2D

@onready var animatedSprite :AnimatedSprite2D = $AnimatedSprite2D 
@onready var label : Label = $Label
@export var creates_blood_particle : bool = false
@export var creates_stat_particle_debuff : bool = true
@export var creates_stat_particle_buff : bool = true
@export var reverse_glow : bool = false
@export var fades_out_at_zero : bool = false

var stat_particle = preload("res://baseball/stat_particle.tscn")
var blood_particle = preload("res://baseball/blood_particle.tscn")

var stat
var faded_out = false

func _ready() -> void:
	return

func set_stat(num : int):
	stat = num
	label.text = str(num)
	if(fades_out_at_zero && stat == 0):
		animatedSprite.play("faded_out")
		faded_out = true
	elif(fades_out_at_zero && stat != 0 &&
	faded_out == true):
		animatedSprite.play("default")
		faded_out = false

func get_stat():
	return stat

func glow():
	animatedSprite.play("glow",3)

func handle_particles(buff_num):
	if(creates_stat_particle_buff && buff_num > 0):
		var num_particle = stat_particle.instantiate()
		add_child(num_particle)
		num_particle.global_position = Vector2(global_position.x,global_position.y)
		num_particle.set_and_fire(buff_num)
	if(creates_stat_particle_debuff && buff_num < 0):
		var num_particle = stat_particle.instantiate()
		add_child(num_particle)
		num_particle.global_position = Vector2(global_position.x,global_position.y)
		num_particle.set_and_fire(buff_num)
	if(creates_blood_particle):
		var particles_amt = abs(buff_num) * 3
		while(particles_amt > 0):
			particles_amt = particles_amt - 1
			var new_blood_particle = blood_particle.instantiate()
			get_parent().get_parent().get_parent().add_child(new_blood_particle)
			new_blood_particle.global_position = Vector2(global_position.x,global_position.y)

func modify_stat(buff_num : int):
	if(buff_num > 0 || reverse_glow):
		animatedSprite.play("glow",3)
	else:
		animatedSprite.play("fade",3)
	handle_particles(buff_num)
	set_stat(stat + buff_num)

func _physics_process(delta: float) -> void:
	if(fades_out_at_zero && faded_out == true):
		animatedSprite.play("faded_out")
	elif(animatedSprite.frame == 7):
		animatedSprite.play("default")
