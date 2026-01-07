extends Sprite2D

@export var running_hours : Array[bool]

@export var active_at_low : bool = false #0
@export var active_at_mid : bool = false #1
@export var active_at_hi : bool = false #2

var time_keeper = null

var pruned : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	add_to_group("timed_light")
	update_light()

func _exit_tree() -> void:
	pruned = true

func _enter_tree():
	if(pruned):
		update_light()
		pruned = false

func update_light():
	if((SettingsVariables.lighting_index == 0 && active_at_low) ||
	(SettingsVariables.lighting_index == 1 && active_at_mid) ||
	(SettingsVariables.lighting_index == 2 && active_at_hi)):
		visible = running_hours[time_keeper.clock]
	else:
		visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
	#if((SettingsVariables.lighting_index == 0 && active_at_low) ||
	#(SettingsVariables.lighting_index == 1 && active_at_mid) ||
	#(SettingsVariables.lighting_index == 2 && active_at_hi)):
		#visible = running_hours[time_keeper.clock]
	#else:
		#visible = false
