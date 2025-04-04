extends CharacterBody2D

@export var bullet_scene: PackedScene 
@export var shoot_range: float = 400   
@export var shoot_delay: float = 1.5   

@onready var shoot_timer = $ShootTimer
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _physics_process(delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 40  
		if global_position.distance_to(player.global_position) > shoot_range:
			move_and_slide()

func _on_shoot_timer_timeout():
	if player and global_position.distance_to(player.global_position) <= shoot_range:
		shoot()

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position  
		bullet.direction = global_position.direction_to(player.global_position)  
		get_tree().get_root().add_child(bullet)
