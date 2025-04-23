extends Node2D

@export var beam_length : float = 300

@onready var beam: Line2D = $Beam

@onready var audio: AudioStreamPlayer2D = $Audio
@onready var ray_cast: RayCast2D = $RayCast




var _is_active : bool 


func _set_length(length: float) -> void:
	beam.points[1].x = length

func activate():
	if !_is_active:
		_is_active = true
		visible = true
		ray_cast.enabled = true
		ray_cast.force_raycast_update()
		_check_laser_hit()
		audio.play()

func deactivate():
	if _is_active:
		_is_active = false
		visible = false
		ray_cast.enabled = false
		audio.stop()
		
	

func _ready() -> void:
	visible = false
	_is_active = false
	_set_length(beam_length)
	ray_cast.enabled = false #only detect when laser active
	ray_cast.target_position.x = beam_length

func _check_laser_hit() -> void:
	if ray_cast.is_colliding():
			_set_length(to_local(ray_cast.get_collision_point()).x)

func _physics_process(delta: float) -> void:
	if _is_active:
		if ray_cast.is_colliding():
			_set_length(to_local(ray_cast.get_collision_point()).x)
			
