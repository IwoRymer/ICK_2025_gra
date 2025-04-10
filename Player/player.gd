extends CharacterBody2D

## Floating motion mode - lewituje - w miejscu
## Grounded - spada na dół ekranu

var movement_speed = 40.0
var hp = 80

var healing_amount = 10
var healing_cooldown = 5 #s

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

func take_damage(dmg: int):
	hp -= dmg
	print("pocisk ",hp)

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
