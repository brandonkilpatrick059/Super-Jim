extends PointLight2D

var player_ref = null
var energy_max : float = 0.0

@export var distance : float = 200
@export var cutoff : float = 100

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	energy_max = energy


func _physics_process(delta: float) -> void:
	var distance_to_player = global_position.distance_to(player_ref.global_position)
	if(distance_to_player < distance):
		if(distance_to_player <= cutoff):
			energy = 0.0
		else:
			energy = energy_max * ((distance_to_player-cutoff)/distance)
	else:
		energy = energy_max
