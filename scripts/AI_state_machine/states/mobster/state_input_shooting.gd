class_name Input_Shooting_State
extends State

signal shoot(pos : Vector2, rotation_deg)
signal throw_bomb()
signal play_animation(name : String)
signal stop_motion()
signal reduce_health()
signal drop_item()

#gun-related variables
const bust_num_sweeps = 2
const burst_bullets_per_sweep = 4
const burst_num_bullets = bust_num_sweeps * burst_bullets_per_sweep
const burst_cool_down_secs = 2
var timer_burst_cool_down : Timer = Timer.new()
const time_between_shots_secs = 0.4
const time_between_shots_secs_fast = 0.1
var timer_between_shots : Timer = Timer.new()
const shoot_arc_degrees = 50 #keep it even
var num_bullets_fired = 0
var lower_bound = 0
var upper_bound = 0
var reverse_sweep = false
var burst_cool_down = false

var random = RandomNumberGenerator.new()

func set_shoort_arc_bounds():
	var half_arc = shoot_arc_degrees / 2
	match(ai_state_machine.get_perceptions().facing_dir):
		direction.right:
			lower_bound = 0 - half_arc
			upper_bound = 0 + half_arc
		direction.left:
			lower_bound = 180 - half_arc
			upper_bound = 180 + half_arc
		direction.up:
			lower_bound = 270 - half_arc
			upper_bound = 270 + half_arc
		direction.down:
			lower_bound = 90 - half_arc
			upper_bound = 90 + half_arc

func create_bullet():
	var bullet_spawn_point = ai_state_machine.get_perceptions().position
	var half_arc = shoot_arc_degrees / 2
	var spawn_distance = 20
	var gun_pos_tweak = 5
	match(ai_state_machine.get_perceptions().facing_dir):
		direction.right:
			bullet_spawn_point = bullet_spawn_point + Vector2(spawn_distance,0)
		direction.left:
			bullet_spawn_point = bullet_spawn_point + Vector2(-spawn_distance,0)
		direction.up:
			bullet_spawn_point = bullet_spawn_point + Vector2(gun_pos_tweak,-spawn_distance)
		direction.down:
			bullet_spawn_point = bullet_spawn_point + Vector2(-gun_pos_tweak,spawn_distance)
	
	var arc_segment_degrees = shoot_arc_degrees / burst_bullets_per_sweep
	var current_segment = num_bullets_fired 
	while(current_segment > burst_bullets_per_sweep):
		reverse_sweep = !reverse_sweep
		current_segment = current_segment - burst_bullets_per_sweep
	
	var current_arc = 0
	if(reverse_sweep):
		current_arc = (upper_bound - (arc_segment_degrees * current_segment))
	else:
		current_arc = (lower_bound + (arc_segment_degrees * current_segment))
	
	shoot.emit(bullet_spawn_point, current_arc)

func handle_knockout() -> bool:
	#knockout when player throws object
	for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(node != null &&
				!ai_state_machine.get_perceptions().invincible &&
				node.is_in_group("spark") &&
				!node.is_in_group("red") &&
				!node.is_in_group("blu")):
				ai_state_machine.transition_to(mobster_states.falling)
				return true
	return false

func shoot_burst():
	set_shoort_arc_bounds()
	play_animation.emit(str("shoot_",ai_state_machine.get_perceptions().facing_dir))
	if(timer_between_shots.is_stopped() 
		&& num_bullets_fired < burst_num_bullets):
		if(ai_state_machine.get_perceptions().team == "blu" &&
		ai_state_machine.get_perceptions().is_bandit):
			var num_bullet_blast = 3
			var b_num = 0
			while(b_num < num_bullet_blast):
				create_bullet()
				b_num = b_num + 1
				num_bullets_fired = num_bullets_fired + 1
		else:
			create_bullet()
		num_bullets_fired = num_bullets_fired + 1
		if(ai_state_machine.get_perceptions().team == "red" &&
		ai_state_machine.get_perceptions().is_bandit):
			timer_between_shots.start(time_between_shots_secs_fast)
		else:
			timer_between_shots.start(time_between_shots_secs)
	else: if(num_bullets_fired >= burst_num_bullets):
		if(ai_state_machine.get_perceptions().is_bandit):
			throw_bomb.emit()
		burst_cool_down = true
		ai_state_machine.transition_to(mobster_states.input_move)
		#timer_burst_cool_down.start(burst_cool_down_secs)	

func physics_process(_delta: float) -> void:
	if(handle_knockout()):
		return
	else:
		#if(Input.is_action_just_released("interact")):
			#ai_state_machine.transition_to(mobster_states.input_move)
		if(!burst_cool_down):
			shoot_burst()
		if(timer_burst_cool_down.is_stopped() && burst_cool_down):
			burst_cool_down = false
			num_bullets_fired = 0
			#ai_state_machine.transition_to(mobster_states.input_move)

func _ready():
	timer_burst_cool_down.one_shot = true
	add_child(timer_burst_cool_down)
	timer_between_shots.one_shot = true
	add_child(timer_between_shots)

func enter(_msg := {}) -> void:
	stop_motion.emit()
	drop_item.emit()
	num_bullets_fired = 0

func exit() -> void:
	pass
