extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const SPEED = 400
var linear_velocity = Vector2(SPEED, 0)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	var collision = move_and_collide(linear_velocity * delta)
	if collision:
		if collision.collider.get_parent().get_name() == "Drone":
			self._on_touch_Drone(delta, collision)
		elif collision.collider.get_parent().get_name() == "PlainBall":
			self._on_touch_Ball(delta, collision)
		elif collision.collider.get_parent().get_name() == "EnemyPaddle":
			self._on_touch_EnemyPaddle(delta, collision)
	self.position += linear_velocity * delta

func _on_touch_Drone(delta, collision):
	# emit damage and impulse
	collision.collider.emit_signal('damage')
	collision.collider.apply_impulse(
		self.position,
		self.linear_velocity * 2)

	self.blow_up()

func _on_touch_Ball(delta, collision):
	# destroy ball
	$"..".emit_signal('score', 5)
	collision.collider.blow_up()
	self.blow_up()
	pass

func _on_touch_EnemyPaddle(delta, collision):
	# stun?
	collision.collider.emit_signal('stun')
	self.blow_up()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_end_poof():
	self.queue_free()


func _on_visibility_viewport_exited(viewport):
	self.queue_free()


func blow_up():
	if not $bullet.visible:
		# already blowing up
		return
	self.linear_velocity.x *= 0.1
	$collision.disabled = true
	$bullet.hide()
	# poof sprite
	$poof.show()
	$"poof/animation".play("default")
	$poof_sound.play()
