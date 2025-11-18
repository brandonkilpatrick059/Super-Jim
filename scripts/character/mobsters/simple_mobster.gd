extends Node2D

@export var team = "red"
var opposing_team 
var is_bandit = false

func set_up_mobster_team():
	add_to_group(team)
	if(team == "red"):
		opposing_team = "blu"
	else: if (team == "blu"):
		opposing_team = "red"
