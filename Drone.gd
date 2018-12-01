extends RigidBody2D

# TODO should collide OK with horizontal walls

const Paddle = preload("res://Paddle.tscn")

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal hit
signal damage

export (bool) var attacking = false
export (float) var thrust_force = 320
# seconds before going berserk
export var patience = 18
export (Rect2) var fly_rect = Rect2(360, 50, 140, 300)
export (int) var health = 3
var target_position = Vector2(320, 200)
var window_size

func reset_destination():
	self.target_position = Vector2(
		self.fly_rect.position.x + randf() * self.fly_rect.size.x,
		self.fly_rect.position.y + randf() * self.fly_rect.size.y
	)

func on_spawned(emitter, arg0, arg1):
	if arg0:
		self.thrust_force = arg0
	if arg1:
		self.patience = arg1
	pass

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$"../../..".inc_enemy_count()
	self.window_size = get_viewport_rect()
	self.reset_destination()


func _physics_process(delta):

	# if too high, bounce
	if self.position.y < 6:
		# with a bit of dampening
		self.position.y = 6
		self.linear_velocity.y = abs(self.linear_velocity.y) * 0.7

	# if too low, bounce
	elif self.position.y > self.window_size.size.y - 6:
		# with a bit of dampening
		self.position.y = self.window_size.size.y - 6
		self.linear_velocity.y = -abs(self.linear_velocity.y) * 0.7

	# when attacking, just thrust towards the left
	if self.attacking:
		self.applied_force.y = 0
		self.applied_force.x = -thrust_force
		return
	
	# if patience ran out, attack
	self.patience -= delta
	if self.patience <= 0:
		self.attacking = true
		# activate kamikaze mode
		thrust_force *= 1.5
		$hull.animation = "kamikaze"
		$DroneSound.pitch_scale = 2.0
		$DroneSound.volume_db = -2.2

	# if close enough to the wander target, choose new target
	if self.position.distance_squared_to(self.target_position) < 60:
		self.reset_destination()
	
	# thrust towards the current destination
	var diff_target = self.target_position - self.position
	self.applied_force = diff_target.normalized() * self.thrust_force


func _on_body_entered(body):
	if body.get_name() == "Paddle":
		body.emit_signal('stun', 1.75)
		$"../../..".emit_signal('score', 15)
		self.blow_up()
	elif body.get_name() == "base":
		body.emit_signal('damage')
		self.blow_up()


func blow_up():
	$collision.disabled = true
	$hull.visible = false
	$poof.visible = true
	$"poof/animation".play("default")
	$PoofSound.play()
	$"../../..".dec_enemy_count()


func _on_Drone_hit():
	# always destroy itself when hit by the paddle
	self.blow_up()


func _on_Drone_damage():
	# triggered when something gives it damage (bullets, balls, ...)
	self.health -= 1
	if self.health <= 0:
		self.blow_up()


func _on_end_poof():
	self.queue_free()
