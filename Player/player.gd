extends CharacterBody2D

## Floating motion mode - lewituje - w miejscu
## Grounded - spada na dół ekranu

var movement_speed = 40.0
var hp = 80

#Attacks
var iceSpear = preload("res://Player/ice_spear.tscn")

#Attack timers
@onready var IceSpearTimer = get_node("Attacks/IceSpearTimer")
@onready var IceSpearAtkTimer = get_node("Attacks/IceSpearTimer/IceSpearAttackTImer")

#Ice Spear
var IceSpear_Ammo = 0
var IceSpear_BaseAmmo = 1
var IceSpear_attackspeed = 1.5
var IceSpear_level = 1

#Enemy related
var EnemyClose = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

## delta default = 1/60 s

func _physics_process(delta: float) -> void:
	movement()

func attack():
	if IceSpear_level > 0:
		IceSpearTimer.wait_time = IceSpear_attackspeed
		if IceSpearTimer.is_stopped():
			IceSpearTimer.start()

func _ready() -> void:
	attack()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	## 0 / 1 if action happended
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var movement = Vector2(x_mov, y_mov)
	if movement.x > 0:
		sprite.flip_h = true
	elif movement.x < 0:
		sprite.flip_h = false
	
	if movement != Vector2.ZERO:
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes -1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = movement.normalized()*movement_speed
	move_and_slide()


func _on_hurt_box_hurt(damage: Variant) -> void:
	hp -= damage
	print(hp)
	pass # Replace with function body.


func _on_ice_spear_timer_timeout() -> void:
	IceSpear_Ammo += IceSpear_BaseAmmo
	IceSpearAtkTimer.start()
	pass # Replace with function body.


func get_random_target():
	if EnemyClose.size() > 0:
		return EnemyClose.pick_random().global_position
	else:
		return Vector2.UP
	pass


func _on_ice_spear_attack_t_imer_timeout() -> void:
	if IceSpear_Ammo > 0:
		var IceSpear_Attack = iceSpear.instantiate()
		IceSpear_Attack.position = position
		IceSpear_Attack.target = get_random_target()
		IceSpear_Attack.level = IceSpear_level
		add_child(IceSpear_Attack)
		IceSpear_Ammo -= 1
		if IceSpear_Ammo > 0:
			IceSpearAtkTimer.start()
		else:
			IceSpearAtkTimer.stop()
	pass # Replace with function body.


func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not EnemyClose.has(body):
		EnemyClose.append(body)
	
	pass # Replace with function body.


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if EnemyClose.has(body):
		EnemyClose.erase(body)
	pass # Replace with function body.
