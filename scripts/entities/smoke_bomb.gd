extends Node

@onready var spark = preload("res://effects/fire_cracker_spark.tscn")
@onready var smoke_bomb_smoke = preload("res://effects/smoke_bomb_smoke.tscn")

var timer := Timer.new()
var fuse_secs = 1.5
var smokes : int = 8

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(fuse_secs)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		var commotion_spark = spark.instantiate()
		commotion_spark.global_position = get_parent().global_position
		get_parent().get_parent().add_child(commotion_spark)
		while(smokes > 0):
			var smoke = smoke_bomb_smoke.instantiate()
			smoke.global_position = get_parent().global_position
			get_parent().get_parent().add_child(smoke)
			smokes = smokes - 1
		get_parent().queue_free()
