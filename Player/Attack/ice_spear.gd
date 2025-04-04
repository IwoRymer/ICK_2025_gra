extends Area2D

var level = 1
var hp = 1
var speed = 100
var damage = 5
var knock_ammmount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			hp = 1
			speed = 100
			damage = 5
			knock_ammmount = 100
			attack_size = 1.0

func _physics_process(delta: float) -> void:
	position += angle * speed * delta


func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		queue_free() # object destructor
	


func _on_timer_timeout() -> void:
	queue_free()  # eliminate object after seconds set in Timer
	pass # Replace with function body.
