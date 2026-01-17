@tool
extends Node

@onready var panel1 = $panel1
@onready var panel2 = $panel2
@onready var panel3 = $panel3
@onready var panel4 = $panel4
@onready var panel5 = $panel5
@onready var panel6 = $panel6

@export var switch_point : int = -720
@export var jump_distance : int = 1440
@export var shift_pixels : float = 1
@export var run_in_editor : bool = false

var windows : Array[Node] = []
var timer : Timer = Timer.new()

@export var timer_wait_secs = 0.01

# Called when the node enters the scene tree for the first time.
func _ready():
	windows.append(panel3)
	windows.append(panel4)
	windows.append(panel5)
	windows.append(panel6)
	windows.append(panel1)
	windows.append(panel2)
	timer.one_shot = true
	add_child(timer)
	timer.start(timer_wait_secs)

func shift_scrollers(pixels : float):
	for panel in windows:
		panel.global_position.x -= pixels

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!Engine.is_editor_hint() || run_in_editor):
		if(timer.is_stopped()):
			shift_scrollers(shift_pixels)
			timer.start(timer_wait_secs)
		if(panel1.position.x <= switch_point):
			panel1.position.x += jump_distance
		if(panel2.position.x <= switch_point):
			panel2.position.x += jump_distance
		if(panel3.position.x <= switch_point):
			panel3.position.x += jump_distance
		if(panel4.position.x <= switch_point):
			panel4.position.x += jump_distance
		if(panel5.position.x <= switch_point):
			panel5.position.x += jump_distance
		if(panel6.position.x <= switch_point):
			panel6.position.x += jump_distance
