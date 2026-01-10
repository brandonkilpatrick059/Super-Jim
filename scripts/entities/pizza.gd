extends Node2D

@onready var _prop = $pizza
@onready var _compass =$compass_arrow
@onready var _pointer =$pointer_arrow
@onready var _sprite = $pizza/sprite

var quick_nohits = preload("res://dialog/dialog trees/delivery_trees/quick_nohits.tscn")
var quick_1hit = preload("res://dialog/dialog trees/delivery_trees/quick_1hits.tscn")
var quick_2hit = preload("res://dialog/dialog trees/delivery_trees/quick_2hits.tscn")
var normal_nohits = preload("res://dialog/dialog trees/delivery_trees/normal_nohits.tscn")
var normal_1hit = preload("res://dialog/dialog trees/delivery_trees/normal_1hit.tscn")
var normal_2hit = preload("res://dialog/dialog trees/delivery_trees/normal_2hit.tscn")
var slow_nohits = preload("res://dialog/dialog trees/delivery_trees/slow_nohits.tscn")
var slow_1hit = preload ("res://dialog/dialog trees/delivery_trees/slow_1hit.tscn")
var slow_2hit = preload("res://dialog/dialog trees/delivery_trees/slow_2hit.tscn")
var _3hit = preload("res://dialog/dialog trees/delivery_trees/3hits.tscn")
var wrong_door_dialog = preload("res://dialog/dialog trees/delivery_trees/wrong_door.tscn")
var pizza_select_bubble = preload("res://dialog/pizza_select_bubble.tscn")

var transform_mod

var delivery_doors
var destination_door: Node
var wrong_door_checked = false

var current_guide_point : Vector2

var random = RandomNumberGenerator.new()

var lost = false
var hits = 0

var pizzas = 3
var current_door = 0
var selected_delivery_doors: Array[Node]

var switch_to_pointer_distance = 128

var timer : Timer = Timer.new()
var time_to_deliver_secs = 240

var dialog = preload("res://dialog/dialog.tscn")
var dialog_manager : Node
var delivery_dialog_tree : dialog_tree

var has_been_picked_up_before = false

var selecting_pizza = false
var select_pizza_bubble = null

var use_item_timer : Timer = Timer.new()

func destroy_self():
	if(_prop != null):
		_prop.queue_free()
	if(_compass != null):
		_compass.queue_free()
	if (_pointer != null):
		_pointer.queue_free()
	queue_free()

func pizza_destroyed():
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	player_ref._on_pizza_lost()
	var cook_ref = get_tree().get_first_node_in_group("cook")
	cook_ref.set_schedules_index(3)
	destroy_self()

# Called when the node enters the scene tree for the first time.
func _ready():	
	use_item_timer.one_shot = true
	timer.one_shot = true
	add_child(timer)
	add_child(use_item_timer)
	_compass.visible = false
	_pointer.visible = false
	get_delivery_doors()

func get_delivery_doors():
	delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	var iterator = 0
	var doors_in_tier : Array[Node] = []
	selected_delivery_doors = []
	for door in delivery_doors:
		if(door.get_tier() <= time_keeper.get_days_passed()):
			doors_in_tier.append(door)
	while(iterator < pizzas):
		var random_index = random.randi_range(0,doors_in_tier.size()-1)
		var delivery_door = doors_in_tier[random_index]
		doors_in_tier.remove_at(random_index)
		selected_delivery_doors.append(delivery_door)
		iterator += 1
	destination_door = selected_delivery_doors[0]
	current_door = 0

func distance_to_position(pos: Vector2):
	return _prop.global_position.distance_to(pos)

func get_closest_delivery_point() -> Node:
	var nearest_door = delivery_doors[0]
	for delivery_door in selected_delivery_doors:
		var distance_to_nearest_door = distance_to_position(nearest_door.global_position)
		var distance_to_other_door = distance_to_position(delivery_door.global_position)
		if(distance_to_other_door < distance_to_nearest_door):
			nearest_door = delivery_door
	return nearest_door

func get_closest_indoor_exit() -> Vector2:
	var exits = get_tree().get_nodes_in_group("indoor_exit")
	var nearest_exit = exits[0].global_position
	for exit in exits:
		var distance_to_nearest_exit = distance_to_position(nearest_exit)
		var distance_to_other_point = distance_to_position(exit.global_position)
		if(distance_to_other_point < distance_to_nearest_exit):
			nearest_exit = exit.global_position
	return nearest_exit

func _on_body_entered(body: Node):
	if(body.is_in_group("spark") && 
	(body.is_in_group("red") || body.is_in_group("blu"))):
		damage_pizza()

func update_pizza_stack():
	if(pizzas > 0):
		var num_hits = hits
		if(num_hits > 3):
			num_hits = 3
		_sprite.play(str(pizzas,num_hits))

func damage_pizza():
	hits = hits + 1
	if(hits > 2 && !lost):
		lost = true
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		player_ref._on_pizza_lost()

func _on_prop_collide():
	damage_pizza()
	

func _on_picked_up():
	wrong_door_checked = false
	if(!has_been_picked_up_before):
		timer.start(time_to_deliver_secs)
		has_been_picked_up_before = true
		

func update_select_bubble():
	if(select_pizza_bubble != null):
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		select_pizza_bubble.global_position = player_ref.global_position
		var address = selected_delivery_doors[current_door].get_address()
		select_pizza_bubble.set_label(address)

func use_item():
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	if(!selecting_pizza):
		selecting_pizza = true
		player_ref.set_control_frozen(true)
		player_ref.stop()
		player_ref.set_dialog_panning(true)
		var fx_player = get_tree().get_first_node_in_group("main_fx_player")
		fx_player.stream = load("res://audio/soundFX/maracca.ogg")
		fx_player.play()
		select_pizza_bubble = pizza_select_bubble.instantiate()
		add_child(select_pizza_bubble)
		select_pizza_bubble.global_position = player_ref.global_position
		update_select_bubble()
		use_item_timer.start(0.2)

func update_compass_pointer():
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	_compass.global_position = player_ref.global_position
	_compass.look_at(current_guide_point)
	if(_prop.get_parent().get_parent().is_in_group("daylight_affected_ysort")):
		if(distance_to_position(current_guide_point) < switch_to_pointer_distance):
			_compass.visible = false
			_pointer.global_position = current_guide_point
			_pointer.visible = true
		else:
			_pointer.visible = false
			_compass.visible = true
	else:
		_pointer.visible = false
		_compass.visible = false

func set_wrong_door_chceked(value : bool):
	wrong_door_checked = value

func wrong_door(door : Node):
	dialog_manager = dialog.instantiate()
	dialog_manager.set_speaker_node(door)
	get_parent().add_child(dialog_manager)
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	player_ref.enter_dialog()
	delivery_dialog_tree = wrong_door_dialog.instantiate()
	dialog_manager.add_child(delivery_dialog_tree)
	dialog_manager.set_tree_and_start_dialog(delivery_dialog_tree)
	player_ref.return_pizza()
	wrong_door_checked = false

func deliver_pizza(door : Node2D):
	dialog_manager = dialog.instantiate()
	dialog_manager.set_speaker_node(door)
	get_parent().add_child(dialog_manager)
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	player_ref.enter_dialog()
	
	#delivering destroyed pizza
	if(hits > 2):
		var cook_ref = get_tree().get_first_node_in_group("cook")
		cook_ref.set_schedules_index(3)
		delivery_dialog_tree = _3hit.instantiate()
	#slow
	elif(timer.is_stopped()):
		if(hits == 0):
			delivery_dialog_tree = slow_nohits.instantiate()
		elif(hits == 1):
			delivery_dialog_tree = slow_1hit.instantiate()
		else:
			delivery_dialog_tree = slow_2hit.instantiate()
	#quick
	elif(timer.time_left > time_to_deliver_secs/2):
		if(hits == 0):
			delivery_dialog_tree = quick_nohits.instantiate()
		elif(hits == 1):
			delivery_dialog_tree = quick_1hit.instantiate()
		else:
			delivery_dialog_tree = quick_2hit.instantiate()
	#normal
	elif(timer.time_left < time_to_deliver_secs/2):
		if(hits == 0):
			delivery_dialog_tree = normal_nohits.instantiate()
		elif(hits == 1):
			delivery_dialog_tree = normal_1hit.instantiate()
		else:
			delivery_dialog_tree = normal_2hit.instantiate()
	
	dialog_manager.add_child(delivery_dialog_tree)
	dialog_manager.set_tree_and_start_dialog(delivery_dialog_tree)	
	pizzas -= 1
	wrong_door_checked = false
	if(pizzas > 0):
		player_ref.return_pizza()
		selected_delivery_doors.erase(door)
		destination_door = selected_delivery_doors[0]
		current_door = 0
	else:
		var pizza_kitchen_door = get_tree().get_first_node_in_group("kitchen_door")
		pizza_kitchen_door.unlock()
		var cook_ref = get_tree().get_first_node_in_group("cook")
		if(hits < 3):
			cook_ref.set_schedules_index(1)
		destroy_self()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	if(_prop != null):
		var pizza_kitchen_door = get_tree().get_first_node_in_group("kitchen_door")
		pizza_kitchen_door.lock()
		update_pizza_stack()
		if(_prop.is_picked_up() && 
		_prop.get_parent().is_in_group("player") && 
		!_prop.get_parent().dead):
			if(selecting_pizza):
				var player_ref = get_tree().get_nodes_in_group("player")[0]
				if(use_item_timer.is_stopped()  && 
				Input.is_action_just_pressed("use_item")):
					player_ref.set_use_item_timer(0.5)
					player_ref.set_control_frozen(false)
					player_ref.set_dialog_panning(false)
					var fx_player = get_tree().get_first_node_in_group("main_fx_player")
					fx_player.stream = load("res://audio/soundFX/maracca.ogg")
					fx_player.play()
					select_pizza_bubble.queue_free()
					selecting_pizza = false
				else:
					player_ref.stop()
					update_select_bubble()
					if(Input.is_action_just_pressed(direction.right)):
						if(current_door + 1 < selected_delivery_doors.size()):
							current_door = current_door + 1
						else:
							current_door = 0
					elif(Input.is_action_just_pressed(direction.left)):
						if(current_door - 1 >= 0):
							current_door = current_door - 1
						else:
							current_door = selected_delivery_doors.size() - 1
					destination_door = selected_delivery_doors[current_door]
				
			if(distance_to_position(destination_door.global_position) < switch_to_pointer_distance):
				current_guide_point = destination_door.global_position
			else:
				var outer_door = destination_door.get_parent_door()
				current_guide_point = outer_door.global_position
			update_compass_pointer()
		else:
			_compass.visible = false
			_pointer.visible = false
			if(!_prop.is_picked_up()):
				var delivered = false
				for door in selected_delivery_doors:
					if(_prop.global_position.distance_to(door.global_position) < 32):
						deliver_pizza(door)
						delivered = true
						break
				if(!delivered):
					for door in delivery_doors:
						if(_prop.global_position.distance_to(door.global_position) < 32):
							wrong_door(door)
							break
					wrong_door_checked = true
					
	else:
		destroy_self()
