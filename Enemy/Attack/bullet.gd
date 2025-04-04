extends Area2D

@export var speed: float = 100
@export var damage: int = 1
var direction: Vector2

func _ready():
	$Timer.start()  

func _process(delta):
	position += direction * speed * delta  

func _on_timer_timeout():
	queue_free() 

func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):  
		area.get_parent().take_damage(damage)  
		queue_free()
