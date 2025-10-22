extends Node2D

@onready var sprite :AnimatedSprite2D = $AnimatedSprite2D
@onready var light :AdvancedLight = $advanced_light

@export var running_hours : Array[bool]
@export var running_hours_2 : Array[bool]
@export var running_hours_3 : Array[bool]
@export var running_hours_4 : Array[bool]

var active_hours : Array[bool]
var current_hour = 0

var time_keeper = null

var random : RandomNumberGenerator = RandomNumberGenerator.new()

func turn_light_on():
	sprite.play("active")
	light.turn_light_on()

func turn_light_off():
	sprite.play("dark")
	light.turn_light_off()

func set_light(on : bool):
	if(on):
		turn_light_on()
	else:
		turn_light_off()

func get_active_hours():
	active_hours = running_hours
	if(running_hours_2.size() > 0):
		if(random.randf_range(0,1) < 0.5):
			active_hours = running_hours_2
	if(running_hours_3.size() > 0):
		if(random.randf_range(0,1) < 0.25):
			active_hours = running_hours_3
	if(running_hours_4.size() > 0):
		if(random.randf_range(0,1) < 0.10):
			active_hours = running_hours_4

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	get_active_hours()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(time_keeper.clock != current_hour):
		current_hour = time_keeper.clock #this code only runs once per hour
		if(time_keeper.clock == 0):
			get_active_hours()
		set_light(active_hours[current_hour])
		
