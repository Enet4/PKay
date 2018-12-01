extends Node2D

# class member variables go here
export (int) var wave_seed = -1

signal emergency
signal score
signal wave_end
signal game_over

export (int) var score = 0

var num_enemies = 0

var timeout = false

export (Resource) var wave_strategy = null


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	if wave_seed != -1:
		rand_seed(wave_seed)
	$"HUD/LblScore".text = str(score)

func _input(event):
	if event is InputEventMouseMotion:
		pass

	if event.is_action_pressed("ui_pause"):
		get_tree().paused = true
		$pause_popup.show()

	if event.is_action_released("ui_accept") or event.is_action_released("ui_select"):
		if self.timeout and self.num_enemies == 0:
			self._on_NextPhaseTimer_timeout()
	pass

func _on_wave_score(value):
	score += value
	$"HUD/LblScore".text = str(score)


func _on_wave_end():
	$"wave-complete".show()
	$BGM_noguitar.volume_db = -4
	if $BGM_withguitar.volume_db > -4:
		$BGM_withguitar.volume_db = -4
	$NextPhaseTimer.start()


func _on_wave_emergency():
	# spawn temporary message
	$emergency.show()
	$"emergency/EmergencyInfoTimer".start()
	# replace BGM
	$BGM_noguitar.stop()
	$BGM_withguitar.volume_db = -0.65
	$AudioEmergency.play()
	# trigger emergency more in all emitters
	for e in $emitter.get_children():
		e.emit_signal('emergency')


func _on_EmergencyTimer_timeout():
	self.emit_signal('emergency')


func _on_TimeoutTimer_timeout():
	self.timeout = true
	$EmergencyTimer.stop()
	# stop all emitters
	for e in $emitter.get_children():
		e.emit_signal('stop')
	# check if enemies are still around
	if self.num_enemies == 0:
		self._on_wave_end()


func _on_wave_game_over():
	$"game-over".show()
	$EmergencyTimer.stop()
	$TimeoutTimer.stop()
	$BGM_noguitar.stop()
	$BGM_withguitar.stop()
	$GameOverTimer.start()


func _on_GameOverTimer_timeout():
	$BGM_noguitar.stop()
	$BGM_withguitar.stop()
	self.get_parent().title_screen()


func _on_NextPhaseTimer_timeout():
	$BGM_noguitar.stop()
	$BGM_withguitar.stop()
	self.get_parent().next_phase()


func _on_EmergencyInfoTimer_timeout():
	$emergency.hide()


func inc_enemy_count():
	self.num_enemies += 1


func dec_enemy_count():
	self.num_enemies -= 1
	if self.timeout and self.num_enemies == 0:
		self._on_wave_end()

