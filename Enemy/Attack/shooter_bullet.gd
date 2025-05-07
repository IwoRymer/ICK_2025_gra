extends Area2D


var level = 2
@export var hp = 1

@export var speed = 125
@export var initial_damage = 0
@export var final_damage = 1
var damage = 0


var target = Vector2.ZERO

var angle = Vector2.ZERO




func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)

func _physics_process(delta: float) -> void:
	position += angle*speed*delta

func target_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		queue_free()



func _on_destructor_t_imer_timeout() -> void:
	queue_free()
	pass # Replace with function body.



func _on_damage_timer_timeout() -> void:
	damage = final_damage
	pass # Replace with function body.


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):  
		area.get_parent().take_damage(damage)  
		queue_free()
	pass # Replace with function body.
