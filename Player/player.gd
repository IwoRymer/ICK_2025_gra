extends CharacterBody2D

## Floating motion mode - lewituje - w miejscu
## Grounded - spada na dół ekranu

var movement_speed = 40.0
var hp = 80

var healing_amount = 10
var healing_cooldown = 5 #s

var can_use_shield = true
var shield_active = false
var shield_duration = 3.0 

@onready var shield_node = $Shield
@onready var shield_timer = $shieldTimer
@onready var shield_cooldown_timer = $shieldCooldownTimer

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")
@onready var healTimer = get_node("%healTimer")

## delta default = 1/60 s

func _physics_process(delta: float) -> void:
	movement()
	
func _ready():
	add_to_group("player")
	healTimer.wait_time = healing_cooldown

func _process(delta):
	if Input.is_action_just_pressed("heal"):
		heal(healing_amount)
	if Input.is_action_just_pressed("shield"):
		activate_shield()

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
	if shield_active:
		print("Tarcza aktywna – brak obrażeń")
		return
	hp -= damage
	print(hp)


func take_damage(dmg: int):
	if shield_active:
		print("Tarcza aktywna – brak obrażeń")
		return
	hp -= dmg
	print("pocisk ", hp)


func heal(dmg: int):
	if healTimer.is_stopped():
		hp += dmg
		sprite.self_modulate.g = 0.3
		sprite.self_modulate.b = 0.3
		
		healTimer.start()
		
func _on_heal_timer_timeout() -> void:
	sprite.self_modulate.g = 1
	sprite.self_modulate.b = 1

func _on_udp_server_client_control(control_vals: Variant) -> void:
	if control_vals[0] != null:
		if control_vals[0][0] == "1":
			heal(healing_amount)
		if control_vals[0][0] == "2": 
			activate_shield()
			
			
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

func _on_shield_cooldown_timer_timeout() -> void:
	can_use_shield = true
