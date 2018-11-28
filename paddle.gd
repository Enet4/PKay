extends KinematicBody2D

signal stun

const Bullet = preload("res://Bullet.tscn")

export (bool) var has_gun = false
export (int) var length = 36
export (float) var max_speed = 200
export (float) var move_decay = 450
export (float) var move_acceleration = 500
export (float) var stun_vulnerability = 1

var stunned = false
var move_vel = 0
var gun_recoiling = false

func _ready():
	if length != null:
		set_paddle_length(length)
	if has_gun:
		$CenterGunBase.show()

func _process(delta):
	var move_up = Input.is_action_pressed("Paddle_move_up")
	var move_down = Input.is_action_pressed("Paddle_move_down")
	var max_speed = self.max_speed
	if self.stunned:
		max_speed *= 0.4
		
	# move up and down based on input
	if move_up:
		move_vel -= move_acceleration * delta
		move_vel = max(move_vel, -max_speed)
	if move_down:
		move_vel += move_acceleration * delta
		move_vel = min(move_vel, max_speed)
	
	if !move_up and !move_down:
		# deccelerate a bit
		if move_vel > 0:
			move_vel = max(0, move_vel - move_decay * delta)
		else:
			move_vel = min(0, move_vel + move_decay * delta)

	position.y += self.move_vel * delta
	if position.y < self.length / 2 + 2:
		position.y = self.length / 2 + 2
		move_vel = 0
	if position.y >= get_viewport_rect().size.y - self.length / 2 - 1:
		position.y = get_viewport_rect().size.y - self.length / 2 - 1
		move_vel = 0
	
	if self.has_gun and !self.gun_recoiling:
		var fire_gun = Input.is_action_pressed("Paddle_fire")
		if fire_gun:
			self.fire_gun()

func _stun_look(is_stunned):
	var color
	if is_stunned:
		color = Color(1, 0.5, 0.5, 1)
	else:
		color = Color(1, 1, 1, 1)

	$EdgeUp.modulate = color
	$EdgeDown.modulate = color
	$Shaft.modulate = color


func set_paddle_length(new_length):
	self.length = new_length
	# 1. set edge sprites' positions
	$EdgeUp.position.y = -(new_length + 4) / 2
	$EdgeDown.position.y = -$EdgeUp.position.y
	# 2. set torso sprites' position and scale (not centered)
	$Shaft.scale.y = new_length - 8
	$Shaft.position.y = $EdgeUp.position.y + 6
	# 3. set collision object's height dimension
	$collision.shape.extents.y = new_length


func fire_gun():
	var bullet = Bullet.instance()
	bullet.position.x = self.position.x + 8
	bullet.position.y = self.position.y
	$"..".add_child(bullet)
	$GunFireSound.play()
	$GunRecoilTimer.start()
	$"muzzle-fire".show()
	$"muzzle-fire/MuzzleFireTimer".start()
	self.gun_recoiling = true


func _on_touch_Drone(drone):
	print("paddle touched a drone: ", drone)
	drone.blow_up()
	pass

func _on_Paddle_stun(amount):
	self.stun_time = amount * stun_vulnerability
	self._stun_look(true)


func _on_GunRecoilTimer_timeout():
	self.gun_recoiling = false


func _on_StunTimer_timeout():
	self.stunned = false
	self._stun_look(false)


func _on_MuzzleFireTimer_timeout():
	$"muzzle-fire".hide()
