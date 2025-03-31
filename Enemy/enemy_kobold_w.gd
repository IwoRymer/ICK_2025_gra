extends CharacterBody2D

@export var movement_speed = 20.0
@export var hp = 10

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var animation  = $AnimationPlayer

func _ready():
	animation.play("walk")

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_collide(velocity * delta)
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x <= -0.1:
		sprite.flip_h = false
	
	


func _on_hurt_box_hurt(damage: Variant) -> void:
	hp -= damage
	if hp <= 0:
		queue_free()
	pass # Replace with function body.
