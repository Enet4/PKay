extends KinematicBody2D

const Paddle = preload("res://Paddle.tscn")

signal hit

var linear_velocity = Vector2(-1, 0)
var hit = false

export (int) var ball_speed = 100

onready var initial_pos = self.position

func _ready():
	$"../../..".inc_enemy_count()
	self.linear_velocity *= self.ball_speed

func on_spawned(emitter, speed, _arg1):
	# roll 1d3, apply vertical velocity
	if randi() % 3 == 1:
		# rotate a bit
		self.linear_velocity.x = -0.9
		self.linear_velocity.y = randf() * 2 - 1
	if speed > 0:
		self.ball_speed = speed

func _physics_process(delta):
	# bounce to stuff, no dampening
	var collision = move_and_collide(linear_velocity * delta)
	if collision:
		var collided_name = collision.collider.get_name()
		match collided_name:
			"Paddle":
				self._on_touch_Paddle(collision)
			"base":
				self._on_touch_Base(collision)
			"ceiling":
				linear_velocity = linear_velocity.bounce(collision.normal)
			"floor":
				linear_velocity = linear_velocity.bounce(collision.normal)
			_:
				var parent_name = collision.collider.get_parent().get_name()
				match parent_name:
					"Drone":
						self._on_touch_Drone(collision)
					"PlainBall":
						self._on_touch_Ball(collision)
					"EnemyPaddle":
						self._on_touch_EnemyPaddle(collision)
					"Barrier":
						self._on_touch_Barrier(collision)
	if abs(self.linear_velocity.x) < 10:
		self.linear_velocity.x *= 1.2

	#position += linear_velocity * self.ball_speed * delta

	# if ball moved off the screen
	if self.position.x > get_viewport_rect().size.x and self.linear_velocity.x > 0:
		if self.hit and $Sprite.visible:
			$"../../..".emit_signal('score', 5)
		self.blow_up()

func _on_touch_Paddle(collision):
	if self.hit:
		# already hit, let it be
		return
	
	# mark as hit by the player
	self.hit = true
	self.set_collision_mask_bit(1, true)
	self.set_collision_mask_bit(2, true)
	
	var normal = collision.normal
	if abs(normal.y) < 0.01:
		self.position.x = collision.collider.position.x + 14
		# tweak collision normal depending on where it was touched
		# at the paddle's front
		normal = self._paddle_normal_tweak(collision)
		var vx = linear_velocity.x
		linear_velocity = linear_velocity.bounce(normal)
		linear_velocity.x = -vx
	else:
		linear_velocity = linear_velocity.bounce(normal)
		
	$AudioBump.play()

func _on_touch_Barrier(collision):
	# bounce normally and destroy barrier
	collision.collider.blow_up()
	linear_velocity = linear_velocity.bounce(collision.normal)
	$AudioBump.play()

func _on_touch_Ball(collision):
	var ball = collision.collider
	if self.hit or ball.hit:
		# since either one was already hit by the paddle,
		# they destroy each other mutually
		$"../../..".emit_signal('score', 10)
		ball.blow_up()
		self.blow_up()
	# otherwise ignore each other


func _on_touch_Base(collision):
	self.hit = true
	# damage base, then blow up
	collision.collider.emit_signal('damage')
	self.blow_up()


func _on_touch_Drone(collision):
	if self.hit:
		# damage drone, score, and blow up
		collision.collider.emit_signal('damage')
		collision.collider.apply_impulse(
			self.position,
			collision.collider.linear_velocity * -10)
		$"../../..".emit_signal('score', 5)
		self.blow_up()
	# otherwise do nothing, just go through it


func _on_touch_EnemyPaddle(collision):
	if self.hit:
		# un-hit the ball
		self.hit = false
		self.set_collision_mask_bit(1, false)
		self.set_collision_mask_bit(2, false)
		# same logic as the player paddle here
		# tweak collision normal depending on where it was touched
		var normal = self._paddle_normal_tweak(collision)
		linear_velocity = linear_velocity.bounce(normal)
	# if not hit, let it go through


func _paddle_normal_tweak(collision):
	var y_diff = self.position.y - collision.collider.position.y
	var normal = collision.normal
	normal.y += y_diff * (0.45 / collision.collider.length)
	# no more than this, otherwise it's too much up and down
	normal.y = min(2.25, max(-2.25, normal.y))
	return normal.normalized()


func blow_up():
	if not $Sprite.visible:
		# already blowing up
		return
	$collision.disabled = true
	$Sprite.hide()
	# poof sprite
	$poof.show()
	$"poof/animate".current_animation = "Poof"
	$"poof/animate".play()
	# poof sound
	$AudioPoof.play()
	$"../../..".dec_enemy_count()


func _on_poof():
	self.queue_free()


func _on_PlainBall_hit():
	self.hit = true

