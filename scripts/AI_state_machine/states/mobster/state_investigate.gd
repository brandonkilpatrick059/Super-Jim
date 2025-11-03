class_name Investigate_State
extends State

signal question_bubble()
signal set_target(node : Node)
signal face_pos(pos : Vector2)
signal stop()
signal stand(dir : String)
signal reduce_health()

var timer : Timer = Timer.new()
var investigate_time_secs = 3
var heard_pos : Vector2

func _physics_process(_delta: float) -> void:
	pass

func handle_sparks():
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
				if(is_instance_valid(node) && node.is_in_group("spark")):
					if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
					!ai_state_machine.get_perceptions().invincible):
						reduce_health.emit()
						var assailant_obj = node.get_source_obj()
						set_target.emit(assailant_obj)
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return true
					elif(!ai_state_machine.get_perceptions().invincible &&
					 !node.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						ai_state_machine.transition_to(mobster_states.falling)
						return true
	return false

func handle_death():
	if(ai_state_machine.get_perceptions().hit_points <= 0):
		ai_state_machine.transition_to(mobster_states.falling)
		return true
	return false

func process(_delta: float) -> void:
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
					if(ai_state_machine.get_perceptions().reactive_has_line_of_sight_to_target):
						ai_state_machine.transition_to(mobster_states.enticed)
						return
		#investigate
		if(timer.is_stopped()):
			ai_state_machine.transition_to(mobster_states.look)

func _ready():
	timer.one_shot = true
	add_child(timer)

func enter(_msg := {}) -> void:
	timer.start(investigate_time_secs)
	question_bubble.emit()
	heard_pos = ai_state_machine.get_perceptions().nodes_in_hearing[0].global_position
	stop.emit()
	face_pos.emit(heard_pos)
	stand.emit("")

func exit() -> void:
	pass
