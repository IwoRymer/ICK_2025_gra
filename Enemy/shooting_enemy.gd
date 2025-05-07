extends CharacterBody2D

@export var movement_speed = 30.0
@export var hp = 20
@export var engage_range = 200.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D

@onready var walkTimer = get_node("%WalkTImer")

#Attacks
var bullet_loaded = 0
var bullet_loaded_base = 1
var bullet_level = 2
@export var bullet_attackspeed = 0.75

var bullet = preload("res://Enemy/Attack/shooter_bullet.tscn")

#AttackNodes
@onready var shootTimer = %ShootTImer
@onready var shootAttkTimer = %ShootAttackTimer

func shoot():
	if bullet_level > 0:
		shootTimer.wait_time = bullet_attackspeed
		if shootTimer.is_stopped():
			shootTimer.start()
	pass

func _ready() -> void:
	shoot()
	pass

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	
	var distance = global_position.distance_to(player.global_position)
	if distance > engage_range:
		velocity = direction*movement_speed
		move_and_collide(velocity * delta)
		movement_animation()

	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x <= -0.1:
		sprite.flip_h = false

func movement_animation():
	if walkTimer.is_stopped():
		if sprite.frame >= sprite.hframes -1:
			sprite.frame = 0
		else:
			sprite.frame = 1
		walkTimer.start()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_hurt_box_hurt(damage: Variant) -> void:
	print('new shooter taking damage')
	hp -= damage
	if hp <= 0:
		queue_free()
	pass # Replace with function body.


func _on_shoot_t_imer_timeout() -> void:
	bullet_loaded += bullet_loaded_base
	shootAttkTimer.start()
	pass # Replace with function body.


func _on_shoot_attack_timer_timeout() -> void:
	if bullet_loaded > 0:
		var bullet = bullet.instantiate()
		bullet.global_position = position
		bullet.target = get_player_target()
		bullet.level = bullet_level
		add_child(bullet)
		bullet_loaded -= 1
		if bullet_loaded >0:
			shootAttkTimer.start()
		else:
			shootAttkTimer.stop()
	pass # Replace with function body.
	

func get_player_target():
	return player.global_position
	
	pass
