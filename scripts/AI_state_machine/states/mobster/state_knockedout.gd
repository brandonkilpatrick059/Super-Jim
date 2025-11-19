class_name Knockedout_State
extends State

signal animate(animation : String)
signal reduce_health()
signal adjust_offset(adjustment : Vector2)
var timer := Timer.new() 
var knocked_out_time_secs = 10
var sprite_offset_amt = 16

func physics_process(_delta: float) -> void:
	if(timer.is_stopped()):
		adjust_offset.emit(Vector2(0,-sprite_offset_amt))
		ai_state_machine.transition_to(mobster_states.recovering)

func _ready():
	timer.one_shot = true
	add_child(timer)

func enter(_msg := {}) -> void:
	var player_ref = get_tree().get_first_node_in_group("player")
	var concern_distance = 300
	var g_position = ai_state_machine.get_perceptions().position
	#nearby friendly mobs react to their friend being knocked out
	if(player_ref.global_position.distance_to(g_position) < concern_distance):
		var mobs = get_tree().get_nodes_in_group("mobster")
		for mob in mobs:
			if(mob != null &&
			mob != self.get_parent().get_parent() &&
			mob.is_in_group(ai_state_machine.get_perceptions().team) &&
			mob.global_position.distance_to(g_position) < concern_distance &&
			!mob.is_in_combat()):
				mob._on_set_ai_target(player_ref)
				if(mob.has_line_of_sight_to_target()):
					mob.transition_ai_state_machine(mobster_states.exclaiming)
	animate.emit(str("fallen_",ai_state_machine.perceptions.facing_dir))
	adjust_offset.emit(Vector2(0,sprite_offset_amt))
	timer.start(knocked_out_time_secs)

func exit() -> void:
	pass
