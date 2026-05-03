extends AudioStreamPlayer2D

@export var sounds : Array[AudioStream]
@export var interval_min_secs : float = 0.0
@export var interval_max_secs : float = 1.0
@export var ready_wait : float = 10.0

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(ready_wait)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		stream = sounds[randi_range(0,sounds.size()-1)]
		play()
		timer.start(randf_range(interval_min_secs,interval_max_secs))
		
	
