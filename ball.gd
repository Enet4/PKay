extends KinematicBody2D

const Paddle = preload("res://Paddle.tscn")

signal hit

var linear_velocity = Vector2(-1, 0)
var hit = false

export (int) var ball_speed = 200

onready var initial_pos = self.position

func _ready():
	$"../../..".num_enemies += 1
	print("PlainBall spawned. num_enemies = ", $"../../..".num_enemies)

func on_spawned(emitter, speed):
	# roll 1d3, apply vertical velocity
	if randi() % 3 == 1:
		self.linear_velocity.y = randf() * 2 - 1
	if speed > 0:
		self.ball_speed = speed

func _physics_process(delta):
	# bounce to stuff, no dampening
	var collision = move_and_collide(linear_velocity * delta)
	if collision:
		if collision.collider.get_name() == "Paddle":
			self._on_touch_Paddle(delta, collision)
		if collision.collider.get_name() == "base":
			self._on_touch_Base(delta, collision)
		elif collision.collider.get_parent().get_name() == "Drone":
			self._on_touch_Drone(delta, collision)
		elif collision.collider.get_parent().get_name() == "PlainBall":
			self._on_touch_Ball(delta, collision)
		elif collision.collider.get_parent().get_name() == "EnemyPaddle":
			self._on_touch_EnemyPaddle(delta, collision)
		elif collision.collider.get_parent().get_name() == "Barrier":
			self._on_touch_Barrier(delta, collision)
		else:
			# bounce against any other kind of object
			linear_velocity = linear_velocity.bounce(collision.normal)
	if abs(self.linear_velocity.x) < 0.25:
		print(self, ": not enough horizontal velocity, boosting...")
		self.linear_velocity.x *= 1.25

func _process(delta):
	position += linear_velocity * self.ball_speed * delta

	# if ball moved off the screen
	if self.position.x > get_viewport_rect().size.x and self.linear_velocity.x > 0:
		if self.hit and $Sprite.visible:
			$"../../..".emit_signal('score', 5)
		self.blow_up()


func _on_touch_Paddle(delta, collision):
	if self.hit:
		# already hit, let it be
		return
	
	# mark as hit by the player
	self.hit = true
	self.set_collision_mask_bit(1, true)
	self.set_collision_mask_bit(2, true)
	# tweak collision normal depending on where it was touched
	var normal = self._paddle_normal_tweak(collision)
	linear_velocity = linear_velocity.bounce(normal)

func _on_touch_Barrier(delta, collision):
	# bounce normally and destroy barrier
	collision.collider.blow_up()
	linear_velocity = linear_velocity.bounce(collision.normal)

func _on_touch_Ball(delta, collision):
	var ball = collision.collider
	if self.hit or ball.hit:
		# since either one was already hit by the paddle,
		# they destroy each other mutually
		$"../../..".emit_signal('score', 10)
		ball.blow_up()
		self.blow_up()
	# otherwise ignore each other


func _on_touch_Base(delta, collision):
	self.hit = true
	# damage base, then blow up
	collision.collider.emit_signal('damage')
	self.blow_up()


func _on_touch_Drone(delta, collision):
	if self.hit:
		# damage drone, score, and blow up
		collision.collider.emit_signal('damage')
		collision.collider.apply_impulse(
			self.position,
			collision.collider.linear_velocity * -10)
		$"../../..".emit_signal('score', 5)
		self.blow_up()
	# otherwise do nothing, just go through it


func _on_touch_EnemyPaddle(delta, collision):
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
	# TODO poof sound
	$"../../..".num_enemies -= 1
	print(self, " poofed. num_enemies = ", $"../../..".num_enemies)


func _on_poof():
	self.queue_free()


func _on_PlainBall_hit():
	self.hit = true

