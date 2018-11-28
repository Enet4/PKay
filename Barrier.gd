extends KinematicBody2D


export (float) var speed = 85
var stop_at_x

func _ready():
	self.stop_at_x = 280 + randf() * 240
	pass

func _physics_process(delta):
	if self.position.x > self.stop_at_x:
		self.position.x -= self.speed * delta
		if self.position.x <= self.stop_at_x:
			self.position.x = self.stop_at_x
			$moving.hide()
			$stopped.show()

func blow_up():
	self.queue_free()

func on_spawn(emitter, speed):
	self.speed = speed
