extends Node2D


var mobster = preload("res://entities/characters/NPC/mobsters/mobster.tscn")

var max_mobs_per_team = 30


var spawns_since_bandit = 0
var spawns_until_bandit = 3
var respawn_timer = Timer.new()
var new_mobster_timer_len_secs = 45
var ysort_node
@export var spawner_team = "red"
var opposing_team = "blu"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	ysort_node = get_tree().get_first_node_in_group("daylight_affected_ysort")
	respawn_timer.start(new_mobster_timer_len_secs)
	
	if(spawner_team == "red"):
		opposing_team = "blu"
	else:
		opposing_team = "red"
	add_to_group(spawner_team)


func turn_over():
	var temp = spawner_team
	remove_from_group(temp)
	spawner_team = opposing_team
	opposing_team = temp
	add_to_group(spawner_team)

func _on_body_entered(body: Node):
	if(body.is_in_group("mobster") && 
	body.is_in_group("bandit") && 
	body.is_in_group(opposing_team)):
		turn_over()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var num_current_mobs = 0
	var current_mobs = get_tree().get_nodes_in_group("mobster")
	var current_team_nodes = get_tree().get_nodes_in_group(spawner_team)
	for mob in current_mobs:
		if(mob in current_team_nodes):
			num_current_mobs+=1
	
	if(respawn_timer.is_stopped() && num_current_mobs < max_mobs_per_team):
		var new_mob = mobster.instantiate()
		new_mob.set_team(spawner_team)
		spawns_since_bandit = spawns_since_bandit + 1
		ysort_node.add_child(new_mob)
		if(spawns_since_bandit >= spawns_until_bandit):
			new_mob.make_bandit()
			spawns_since_bandit = 0
		new_mob.global_position = global_position
		respawn_timer.start(new_mobster_timer_len_secs)
