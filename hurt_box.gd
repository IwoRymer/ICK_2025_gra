extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTImer

signal hurt(damage)

func _on_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #cooldown
					collision.call_deferred('set', "disabled", true)
					disableTimer.start()
				1: #HitOnce
					pass
				2: #DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			emit_signal('hurt', damage)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)
	pass # Replace with function body.


func _on_disable_t_imer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
	pass # Replace with function body.
