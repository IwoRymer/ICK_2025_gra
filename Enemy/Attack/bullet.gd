extends Area2D

@export var speed: float = 100
@export var damage_final: int = 1
var damage_start = 0
var damage = damage_start
var direction: Vector2

func _ready():
	$Timer.start()
	$%DamageTimer.start()

func _process(delta):
	position += direction * speed * delta  

func _on_timer_timeout():
	queue_free() 

func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):  
		area.get_parent().take_damage(damage)  
		queue_free()


func _on_damage_timer_timeout() -> void:
	damage = damage_final
	pass # Replace with function body.
