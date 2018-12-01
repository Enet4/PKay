extends Node

signal emergency
signal stop

export (float) var emission_period = 2.5
export (int) var total_enemies_to_emit = 300
export (float) var emitted_speed = 175
export (float) var emitted_arg1 = 1.0
export (PackedScene) var object_class = preload("res://PlainBall.tscn")
export var random_seed = -1
export (float) var emission_time_variance_range = 0.25

# class member variables go here
var enemies_emitted = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.redefine_emission_time()
	#self.emit()
	pass
	

func redefine_emission_time():
	if self.total_enemies_to_emit <= self.enemies_emitted:
		return
	var emission_time = emission_period + (randf() * 2 - 1) * self.emission_time_variance_range
	$EmitTimer.wait_time = emission_time
	$EmitTimer.start()


func emit():
	# emit an enemy
	var new_enemy = self.object_class.instance()
	new_enemy.position.x = 750
	new_enemy.position.y = 30 + randf() * 340
	# on_spawn is called, can be used to
	# tweak speed and whatnot based on the given emitter
	new_enemy.on_spawned(self, self.emitted_speed, self.emitted_arg1)
	enemies_emitted += 1
	var enemy_name = new_enemy.get_name()
	var enemy_node = $"../../enemy".get_node(enemy_name)
	enemy_node.add_child(new_enemy)


func _on_emergency():
	if self.enemies_emitted < self.total_enemies_to_emit:
		# increase emission speed
		self.emission_period *= 0.8
		self.emitted_speed *= 1.2


func _on_stop():
	self.total_enemies_to_emit = 0
	$EmitTimer.stop()


func _on_EmitTimer_timeout():
	self.emit()
	self.redefine_emission_time()
