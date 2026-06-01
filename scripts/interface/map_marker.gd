extends Sprite2D

@export var tab_name : String = ""
@export var linked_map : String = ""
@export var lock_group : String = ""
@export var link_to_tab_name : String = ""

var active : bool = false

var timer := Timer.new()

func _ready() -> void:
	visible = false
	timer.one_shot = true
	add_child(timer)

func get_tab_name() -> String:
	return tab_name

func get_linked_map() -> String:
	return linked_map

func get_lock_group() -> String:
	return lock_group

func get_link_to_tab_name() -> String:
	return link_to_tab_name

func set_active(value : bool):
	active = value
	if(!active):
		visible = false

func _physics_process(delta: float) -> void:
	if(active && timer.is_stopped()):
		visible = !visible
		timer.start(0.5)
