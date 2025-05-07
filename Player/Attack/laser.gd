extends Node2D

@export var beam_length : float = 300
@export var laser_damage = 5

@export var laser_charge_max = 3600
@export var laser_recharge = 10
@export var laser_usage = 10
@export var laser_min_charge = 0 #percent charge min
var laser_charge = laser_charge_max

@onready var beam: Line2D = $Beam
@onready var Glow: Line2D = $Glow

@onready var audio: AudioStreamPlayer2D = $Audio
@onready var ray_cast: RayCast2D = $RayCast

@onready var animation: AnimationPlayer = %animation

var laser_up = 0
var laser_down = 0
var laser_left = 0
var laser_right = 0

var laser_up_old = 0
var laser_down_old = 0
var laser_left_old = 0
var laser_right_old = 0



var _is_active : bool 


func _set_length(x_: float, y_: float) -> void:
	beam.points[1].x = x_
	beam.points[1].y = y_
	Glow.points[1].x = x_
	Glow.points[1].y = y_

func activate():
	if !_is_active:
		_is_active = true
		visible = true
		ray_cast.enabled = true
		var laser_dim = calculate_laser()
		ray_cast.target_position.x = laser_dim[0]
		ray_cast.target_position.y = laser_dim[1]
		ray_cast.force_raycast_update()
		_check_laser_hit()
		audio.play()
		animation.play("start_beam")

func deactivate():
	if _is_active:
		_is_active = false
		ray_cast.enabled = false
		audio.stop()
		animation.play("stop_beam")
		Input.action_release("Fire_laser")
		
func calculate_laser():
	var end_x = 0
	var end_y = beam_length
	var sqrt_2 = 0.7071
	if laser_up && laser_right:
		end_x = beam_length*sqrt_2
		end_y = -beam_length*sqrt_2
	elif laser_up && laser_left:
		end_x = -beam_length*sqrt_2
		end_y = -beam_length*sqrt_2
	elif laser_up:
		end_x = 0
		end_y = -beam_length
	elif laser_down && laser_left:
		end_x = -beam_length*sqrt_2
		end_y = beam_length*sqrt_2
	elif laser_down && laser_right:
		end_x = beam_length*sqrt_2
		end_y = beam_length*sqrt_2
	elif laser_down:
		end_x = 0
		end_y = beam_length
	elif laser_left:
		end_x = -beam_length
		end_y = 0
	elif laser_right:
		end_x = beam_length
		end_y = 0
	
	return [end_x, end_y]

func _ready() -> void:
	visible = false
	_is_active = false
	var laser_dim = calculate_laser()
	_set_length(laser_dim[0], laser_dim[1])
	ray_cast.enabled = false #only detect when laser active
	ray_cast.target_position.x = laser_dim[0]
	ray_cast.target_position.y = laser_dim[1]

func _check_laser_hit() -> void:
	if ray_cast.is_colliding():
			_set_length(to_local(ray_cast.get_collision_point()).x, ray_cast.get_collision_point().y)
			var collider = ray_cast.get_collider()
			if collider && collider.has_method("_on_hurt_box_hurt"):
				collider._on_hurt_box_hurt(laser_damage)
			
func _check_if_atk_changed() -> bool:
	if (laser_up != laser_up_old) || (laser_down != laser_down_old) || (laser_left != laser_left_old) || (laser_right != laser_right_old):
		return true
	else:
		return false

func _physics_process(delta: float) -> void:
	if _is_active:
		#_check_laser_hit()
		if _check_if_atk_changed():
			var laser_dim = calculate_laser()
			ray_cast.target_position.x = laser_dim[0]
			ray_cast.target_position.y = laser_dim[1]
			ray_cast.force_raycast_update()
			_set_length(laser_dim[0], laser_dim[1])
		_check_laser_hit()
		laser_charge = laser_charge - laser_usage
		var collider = ray_cast.get_collider()
		if collider && collider.has_method("_on_hurt_box_hurt"):
			collider._on_hurt_box_hurt(laser_damage)
	else:
		laser_charge = laser_charge + laser_recharge


func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stop_beam":
		visible = false
	pass # Replace with function body.
