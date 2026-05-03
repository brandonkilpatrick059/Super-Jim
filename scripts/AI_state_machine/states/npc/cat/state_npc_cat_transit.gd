class_name NPC_Cat_Transit_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation(speed : int)

@export var speed : float = 125000

var nav_target_reached = false
var host_position

var timer := Timer.new()
var loaded_in = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(5)
	
func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func is_outdoors() -> bool:
	return !ai_state_machine.get_parent().is_indoors()

func physics_process(_delta: float) -> void:
	if(loaded_in):
		var player_ref = get_tree().get_first_node_in_group("player")
		if (player_ref.global_position.distance_to(get_host_position()) < 64 &&
		player_ref.speed() > 4):
			if(is_outdoors()):
				var msg_dict : Dictionary = {"flee_from": player_ref.global_position}
				ai_state_machine.transition_to("transit_flee",msg_dict)
		if(is_outdoors()):
			for commotion in ai_state_machine.get_perceptions().nodes_in_hearing:
				if(commotion != null):
					if(get_host_position().distance_to(commotion.global_position) < 128):
						var msg_dict : Dictionary = {"flee_from": commotion.global_position}
						ai_state_machine.transition_to("transit_flee",msg_dict)
						break
			var bullet_sparks = get_tree().get_nodes_in_group("bullet_spark")
			for spark in bullet_sparks:
				if(spark != null):
					if(get_host_position().distance_to(spark.global_position) < 128):
						var msg_dict : Dictionary = {"flee_from": spark.global_position}
						ai_state_machine.transition_to("transit_flee",msg_dict)
						break
		var cat_foods = get_tree().get_nodes_in_group("cat_food")
		for food in cat_foods:
			if(get_host_position().distance_to(food.global_position) < 128 &&
			get_nearest_point_on_mesh(food.global_position) == food.global_position):
				var msg_dict : Dictionary = {"food_node": food}
				ai_state_machine.transition_to("enticed",msg_dict)
				break
		nav_target_reached = get_host_nav_target_reached()
		if(!nav_target_reached):
			advance_navigation.emit(speed)
		else:
			if(randf_range(0.0,1.0) < 0.25):
				ai_state_machine.transition_to("sit")
			else:
				ai_state_machine.transition_to("transit")
	elif(timer.is_stopped() && !loaded_in):
		loaded_in = true
		ai_state_machine.transition_to("transit")

func has_line_of_sight(point : Vector2) -> bool:
	var npc = ai_state_machine.get_parent()
	var check : bool = npc.active_has_line_of_sight_to_point(point)
	return check

func get_stepped_points_from_pos(pos: Vector2, num_steps, step_distance) -> Array[Vector2]:
	var iterator = 1
	var points : Array[Vector2] = []
	while(iterator <= num_steps):
		var step = step_distance * iterator
		var north = Vector2(pos.x, pos.y - step)
		points.append(north)
		var northEast = Vector2(pos.x + step, pos.y - step)
		points.append(northEast)
		var east = Vector2(pos.x + step, pos.y)
		points.append(east)
		var southEast = Vector2(pos.x + step, pos.y + step)
		points.append(southEast)
		var south = Vector2(pos.x, pos.y + step)
		points.append(south)
		var soutWest = Vector2(pos.x - step, pos.y + step)
		points.append(soutWest)
		var west = Vector2(pos.x - step, pos.y)
		points.append(west)
		var northWest = Vector2(pos.x + step, pos.y)
		points.append(northWest)
		iterator = iterator + 1
	var seen_points : Array[Vector2] = []
	for point in points:
		var seen_point = get_nearest_point_on_mesh(point)
		if(has_line_of_sight(seen_point)):
			seen_points.append(seen_point)
	return seen_points

func get_nearest_point_on_mesh(point : Vector2):
	var npc = ai_state_machine.get_parent()
	var new_point : Vector2 = npc.get_nearest_point_on_mesh(point)
	return new_point

func get_random_point(vectors : Array[Vector2]) -> Vector2:
	if vectors.size() > 0:
		var idx : int = randi_range(0,vectors.size()-1)
		return get_nearest_point_on_mesh(vectors[idx])
	return get_nearest_point_on_mesh(get_host_position())

func enter(_msg := {}) -> void:
	var radius : float = 200
	var stepped_pts = get_stepped_points_from_pos(get_host_position(),1,128)
	var nav_target = get_random_point(stepped_pts)
	set_nav_target.emit(nav_target)

func exit() -> void:
	pass
	
