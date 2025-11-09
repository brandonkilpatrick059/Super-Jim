class_name Look_State
extends State

signal turn_right
signal turn_left
signal stand(direction : String)
signal set_target(target : Node)
signal reduce_health()

const turn_wait_time_secs = 2
const num_turns = 4
var current_num_turns = 0
var timer = Timer.new()

func _physics_process(_delta: float) -> void:
	pass

func handle_sparks():
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(is_instance_valid(node) && node.is_in_group("bullet_spark")):
				#take damage when hit with bullet
				if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
				!ai_state_machine.get_perceptions().invincible):
					reduce_health.emit()
					var assailant_obj = node.get_source_obj()
					set_target.emit(assailant_obj)
					ai_state_machine.transition_to(mobster_states.exclaiming)
					return true
			#knockout when player throws object
			elif(node != null && !ai_state_machine.get_perceptions().invincible && node.is_in_group("spark")):
				ai_state_machine.transition_to(mobster_states.falling)
				return true
	return false

func handle_death():
	if(ai_state_machine.get_perceptions().hit_points <= 0 &&
					!ai_state_machine.get_perceptions().invincible):
		ai_state_machine.transition_to(mobster_states.falling)
		return true
	return false

func physics_process(_delta: float):
	#check knockout
	if(handle_sparks()):
		return
	elif(handle_death()):
		return
	else:
		#check for targets
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		var pizza = get_tree().get_first_node_in_group("pizza")
		#check vision
		#check nodes in vision for other mobs, who take priority
		for node in nodes_in_vision:
			if(node != null):
				if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
				node.is_in_group("mobster")):
					set_target.emit(node)
					if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return
				#check for player
				elif(node.is_in_group("courier")):
					set_target.emit(node)
					if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return
				elif(pizza != null &&
				node.is_in_group("pizza") && 
				!ai_state_machine.perceptions.holding_object &&
				!pizza.is_picked_up()):
					set_target.emit(node)
					if(ai_state_machine.get_perceptions().reactive_has_line_of_sight_to_target || 
					ai_state_machine.get_perceptions().has_line_of_sight_to_target):
						ai_state_machine.transition_to(mobster_states.enticed)
						return
		#check nodes in hearing
		if(nodes_in_hearing.size() > 0):
			for node in nodes_in_hearing:
				if(node.is_in_group("exclaim")):
					var source_obj = node.get_source_obj()
					if(source_obj != null):
						if(source_obj.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
							set_target.emit(source_obj)
							ai_state_machine.transition_to(mobster_states.exclaiming)
							return
			ai_state_machine.transition_to(mobster_states.investigate)
		#check hearing
		elif(nodes_in_hearing.size() > 0):
			for node in nodes_in_hearing:
				if(node.is_in_group("exclaim")):
					var source_obj = node.get_source_obj()
					if(source_obj != null && 
					source_obj.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						set_target.emit(source_obj)
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return
			ai_state_machine.transition_to(mobster_states.investigate)
		#look state code
		elif(timer.is_stopped()):
			if(current_num_turns < num_turns):
				if(ai_state_machine.get_perceptions().team == "red"):
					turn_right.emit()
				else:
					turn_left.emit()
				current_num_turns = current_num_turns + 1
				timer.start(turn_wait_time_secs)
				stand.emit("")
			else:
				ai_state_machine.transition_to(mobster_states.transit)

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func enter(_msg := {}) -> void:
	current_num_turns = 0
	timer.start(turn_wait_time_secs)
	stand.emit("")

func exit() -> void:
	pass
