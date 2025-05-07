extends CharacterBody2D

## Floating motion mode - lewituje - w miejscu
## Grounded - spada na dół ekranu

var movement_speed = 40.0
var maxHp = 80
var hp = maxHp

#Attacks
var iceSpear = preload("res://Player/ice_spear.tscn")
var last_movement = Vector2.UP
var Tornado = preload("res://Player/Attack/tornado.tscn")
@onready var player: CharacterBody2D = $"."
@onready var laser: Node2D = $Laser

var healing_amount = 30
var healing_cooldown = 5 #s

var can_use_shield = true
var shield_active = false
var shield_duration = 4.0 
@onready var healTimer = get_node("%healTImer")

@onready var shield_node = $Shield
@onready var shield_timer = $shieldTimer
@onready var shield_cooldown_timer = $shieldCooldownTImer

#Attack timers
@onready var IceSpearTimer = get_node("Attacks/IceSpearTimer")
@onready var IceSpearAtkTimer = get_node("Attacks/IceSpearTimer/IceSpearAttackTImer")

@onready var TornadoTimer = get_node("%TornadoTimer")
@onready var TornadoAtkTimer = get_node("%TornadoAttackTimer")

#Ice Spear
var IceSpear_Ammo = 0
var IceSpear_BaseAmmo = 1
var IceSpear_attackspeed = 1.5
var IceSpear_level = 1

# Tornado
var Tornado_Ammo = 0
var Tornado_BaseAmmo = 1
var Tornado_attackspeed = 3
var Tornado_level = 1

#Enemy related
var EnemyClose = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")
@onready var hpDisplay = get_node("%HpDisplay")
@onready var gameOverScreen = get_node("%GameOverScreen")

## delta default = 1/60 s

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("heal"):
		heal(healing_amount)
	if Input.is_action_just_pressed("shield"):
		activate_shield()
	if Input.is_action_pressed("Fire_laser"):
		if (laser.laser_charge > (laser.laser_min_charge * laser.laser_charge_max)):
			laser.activate()
		if laser.laser_charge <= 0:
			laser.deactivate()
	else:
		laser.deactivate()
		
	hpDisplay.text = str(hp)
	
	if Input.is_action_pressed("attk_up"):
		laser.laser_up = 1
	else:
		laser.laser_up = 0
	if Input.is_action_pressed("attk_down"):
		laser.laser_down = 1
	else:
		laser.laser_down = 0
	if Input.is_action_pressed("attk_left"):
		laser.laser_left = 1
	else:
		laser.laser_left = 0
	if Input.is_action_pressed("attk_right"):
		laser.laser_right = 1
	else:
		laser.laser_right = 0
		
	#game over
	if hp <= 0:
		#gameOverScreen.set_visible(true)
		pass

func _physics_process(delta: float) -> void:
	movement()
	
func attack():
	if IceSpear_level > 0:
		IceSpearTimer.wait_time = IceSpear_attackspeed
		if IceSpearTimer.is_stopped():
			IceSpearTimer.start()
	
	if Tornado_level > 0:
		TornadoTimer.wait_time = Tornado_attackspeed
		if TornadoTimer.is_stopped():
			TornadoTimer.start()

func _ready() -> void:
	attack()
	add_to_group("player")
	healTimer.wait_time = healing_cooldown


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
		last_movement = movement
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes -1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = movement.normalized()*movement_speed
	move_and_slide()

func heal(dmg: int):
	if healTimer.is_stopped():
		hp += dmg
		hp = min(hp, maxHp)
		sprite.self_modulate.g = 0.3
		sprite.self_modulate.b = 0.3
		
		healTimer.start()

func _on_hurt_box_hurt(damage: Variant) -> void:
	if shield_active:
		print("Tarcza aktywna – brak obrażeń")
		return
	hp -= damage
	#print(hp)
	pass # Replace with function body.


func get_random_target():
	if EnemyClose.size() > 0:
		return EnemyClose.pick_random().global_position
	else:
		return Vector2.UP
	pass

func _on_ice_spear_timer_timeout() -> void:
	IceSpear_Ammo += IceSpear_BaseAmmo
	IceSpearAtkTimer.start()
	pass # Replace with function body.

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

func _on_tornado_timer_timeout() -> void:
	Tornado_Ammo += Tornado_BaseAmmo
	TornadoAtkTimer.start()
	pass # Replace with function body.


func _on_tornado_attack_timer_timeout() -> void:
	if Tornado_Ammo > 0:
		var Tornado_Attack = Tornado.instantiate()
		Tornado_Attack.position = position
		Tornado_Attack.last_movement = last_movement
		Tornado_Attack.level = Tornado_level
		add_child(Tornado_Attack)
		Tornado_Ammo -= 1
		if Tornado_Ammo > 0:
			TornadoAtkTimer.start()
		else:
			TornadoAtkTimer.stop()
	pass # Replace with function body.


func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not EnemyClose.has(body):
		EnemyClose.append(body)
	
	pass # Replace with function body.


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if EnemyClose.has(body):
		EnemyClose.erase(body)
	pass # Replace with function body.

func take_damage(dmg: int):
	if shield_active:
		print("Tarcza aktywna – brak obrażeń")
		return
	hp -= dmg
	#print("pocisk ",hp)


func _on_heal_t_imer_timeout() -> void:
	sprite.self_modulate.g = 1
	sprite.self_modulate.b = 1

func press(action): 
	Input.action_press(action)
	#await get_tree().create_timer(0.5).timeout
	Input.action_release(action)
	
func hold(action):
	Input.action_press(action)
	
func release(action):
	Input.action_release(action)

func _on_udp_server_client_control(control_vals: Variant) -> void:
	#print(control_vals)
	if control_vals[2] != null:
		print(control_vals)
		if control_vals[2][0] == "4":
			heal(healing_amount)
		if control_vals[2][0] == "3": 
			activate_shield()
			
	#movement from openpose
	if control_vals[1] != null:
		print(control_vals)
		if control_vals[1][0] == "1":
			hold("up")
		else:
			release("up")
		if control_vals[1][1] == "1":
			hold("down")
		else:
			release("down")
		if control_vals[1][2] == "1":
			hold("left")
		else:
			release("left")
		if control_vals[1][3] == "1":
			hold("right")
		else:
			release("right")
	
	if control_vals[0] != null:
		print(control_vals)	
		if control_vals[0][5] == "1":
			hold("Fire_laser")
			
func activate_shield():
	if not shield_active and can_use_shield:
		shield_active = true
		can_use_shield = false
		shield_node.visible = true
		shield_node.get_node("ShieldCollision").disabled = false
		shield_timer.start()
		shield_cooldown_timer.start()

func _on_shield_timer_timeout() -> void:
	shield_active = false
	shield_node.visible = false
	shield_node.get_node("ShieldCollision").disabled = true 
	pass # Replace with function body.


func _on_shield_cooldown_t_imer_timeout() -> void:
	can_use_shield = true
	pass # Replace with function body.
