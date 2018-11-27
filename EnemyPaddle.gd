extends KinematicBody2D

signal stun

export (int) var length = 36
export (float) var max_speed = 150
export (float) var move_decay = 700
export (float) var move_acceleration = 700
export (float) var stun_time = 0
export (bool) var entered = false
export (bool) var leaving = false
export (float) var enter_speed = 50
export (float) var stun_vulnerability = 1.25

var target = null
var move_vel = 0

func _ready():
	if length != null:
		_set_paddle_length(length)

func on_spawned(emitter, speed):
	pass

func _process(delta):
	if not entered:
		self.position.x -= self.enter_speed * delta
		if self.position.x < 600:
			self.position.x = 600
			self.entered = true
			$RetargetTimer.start()
			$TTLTimer.start()
	elif leaving:
		self.position.x += self.enter_speed * delta
		if self.position.x > 700:
			self.queue_free()
	
	var move_up = false
	var move_down = false
	if target != null and target.get_ref():
		var t = target.get_ref()
		var diff_y = t.position.y - self.position.y
		if diff_y > self.length / 2 - 8:
			move_down = true
		elif diff_y < -self.length / 2 + 8:
			move_up = true
	
	# move up and down based on decision
	if move_up:
		move_vel -= move_acceleration * delta
		move_vel = max(move_vel, -max_speed)
	elif move_down:
		move_vel += move_acceleration * delta
		move_vel = min(move_vel, max_speed)
	else:
		# deccelerate a bit
		if move_vel > 0:
			move_vel = max(0, move_vel - move_decay * delta)
		elif move_vel < 0:
			move_vel = min(0, move_vel + move_decay * delta)

	position.y += self.move_vel * delta
	if position.y < self.length / 4 + 2:
		position.y = self.length / 4 + 2
		move_vel = 0
	if position.y >= get_viewport_rect().size.y - self.length / 2 - 1:
		position.y = get_viewport_rect().size.y - self.length / 2 - 1
		move_vel = 0

func _set_paddle_length(new_length):
	self.length = new_length
	# 1. set edge sprites' positions
	$EdgeUp.position.y = -(new_length + 4) / 2
	$EdgeDown.position.y = -$EdgeUp.position.y
	# 2. set torso sprites' position and scale (not centered)
	$Shaft.scale.y = new_length - 8
	$Shaft.position.y = new_length / 2 - 4
	# 3. set collision object's height dimension
	$collision.shape.extents.y = new_length

func _stun_look(is_stunned):
	var color
	if is_stunned:
		color = Color(0.5, 0.5, 0.5, 1)
	else:
		color = Color(1, 1, 1, 1)

	$EdgeUp.modulate = color
	$EdgeDown.modulate = color
	$Shaft.modulate = color


func _on_RetargetTimer_timeout():
	# reidentify target based on closest incoming ball
	var ball_node = $"../../PlainBall"
	
	for b in ball_node.get_children():
		if b.hit and (
				self.target == null or
				!self.target.get_ref() or
				b.position.x > self.target.get_ref().position.x
			):
			self.target = weakref(b)


func _on_stun(amount):
	self.stun_time = amount * stun_vulnerability
	self._stun_look(true)