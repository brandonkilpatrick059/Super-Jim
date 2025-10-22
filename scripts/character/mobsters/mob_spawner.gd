extends Node2D


var mobster = preload("res://entities/characters/NPC/mobsters/mobster.tscn")

var max_mobs_per_team = 35

var spawns_since_bandit = 0
var spawns_until_bandit = 3
var friendly_check_timer = Timer.new()
var max_check_wait_secs = 10
var ysort_node
@export var spawner_team = "red"
var opposing_team = "blu"

var friendly_check_radius = 600
var num_nearby_friendlies = 0

var random : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	friendly_check_timer.one_shot = true
	add_child(friendly_check_timer)
	ysort_node = get_tree().get_first_node_in_group("daylight_affected_ysort")
	friendly_check_timer.start(random.randf_range(0,max_check_wait_secs))
	
	if(spawner_team == "red"):
		opposing_team = "blu"
	else:
		opposing_team = "red"
	add_to_group(spawner_team)

func get_num_nearby_friendlies():
	return num_nearby_friendlies

func turn_over():
	var temp = spawner_team
	remove_from_group(temp)
	spawner_team = opposing_team
	opposing_team = temp
	add_to_group(spawner_team)

func check_nearby_friendlies():
	var num = 0
	var mobs  = get_tree().get_nodes_in_group("mobster")
	for mob in mobs:
		if(mob.is_in_group(spawner_team) &&
		global_position.distance_to(mob.global_position) < friendly_check_radius):
			num = num + 1
	num_nearby_friendlies =  num

func spawn_mob():
	var num_team_mobs = 0
	var current_mobs = get_tree().get_nodes_in_group("mobster")
	for mob in current_mobs:
		if(mob.is_in_group(spawner_team)):
			num_team_mobs = num_team_mobs + 1
	if(num_team_mobs < max_mobs_per_team):
		var new_mob = mobster.instantiate()
		new_mob.set_team(spawner_team)
		spawns_since_bandit = spawns_since_bandit + 1
		ysort_node.add_child(new_mob)
		if(spawns_since_bandit > spawns_until_bandit):
			new_mob.make_bandit()
			spawns_since_bandit = 0
		new_mob.global_position = global_position
	

func _on_body_entered(body: Node):
	if(body.is_in_group("mobster") && 
	body.is_in_group("bandit") && 
	body.is_in_group(opposing_team)):
		turn_over()
		body.heal_to_max()

func _physics_process(delta: float) -> void:
	if(friendly_check_timer.is_stopped()):
		check_nearby_friendlies()
		friendly_check_timer.start(random.randf_range(0,max_check_wait_secs))
