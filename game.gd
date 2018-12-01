extends Node

const TITLE_SCENE = preload("res://title.tscn")
const WAVE_SCENE = preload("res://wave.tscn")
const PREPARATION_SCENE = preload("res://prepare.tscn")
const ENDING_SCENE = preload("res://ending.tscn")

# global game state goes here
var score = 0
var wave_num = 0
var credits = 0
var upgrade_status = {
	"speed": 0,
	"stability": 0,
	"forcefield": 0,
	"resistance": 0,
	"gun": 0,
	"gun_rate": 0,
	"length": 0,
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func exit_game():
	self.get_tree().quit()


func new_game():
	score = 0
	wave_num = 0
	upgrade_status = {
		"speed": 0,
		"stability": 0,
		"forcefield": 0,
		"resistance": 0,
		"gun": 0,
		"gun_rate": 0,
		"length": 0,
	}
	self.open_wave()

func open_instructions():
	pass

func title_screen():
	for child in self.get_children():
		child.queue_free()
	var title = TITLE_SCENE.instance()
	self.add_child(title)

func open_wave():
	# called by preparation phase to
	# enter the next wave
	self.wave_num += 1
	var wave = WAVE_SCENE.instance()
	# configure stuff
	# - paddle configurations based on upgrades
	_configure_paddle(wave.get_node("Paddle"))
	# - base configuration based on upgrades
	wave.get_node("base").damaged = -upgrade_status["forcefield"]
	# - other wave configurations based on level
	_configure_wave(wave)

	# transfer the current score
	wave.score = score
		
	# remove other scenes
	for scn in get_children():
		scn.queue_free()
	# add wave scene
	self.add_child(wave)


func next_phase():
	if self.wave_num < 8:
		self.open_preparation()
	else:
		self.open_ending()


func open_preparation():
	self.score = $wave.score
	for child in self.get_children():
		child.queue_free()
	var prepare = self._new_prepare_scene()
	self.add_child(prepare)


func open_ending():
	for child in self.get_children():
		child.queue_free()
	var ending = ENDING_SCENE.instance()
	self.add_child(ending)


func _new_prepare_scene():
	var prepare = PREPARATION_SCENE.instance()
	prepare.status = self.upgrade_status
	prepare.wave_num = self.wave_num
	match self.wave_num: # this is the current wave, not the next one
		1:
			self.credits += 50
			prepare.intelligence = "We have ovecome the first attack, but our scanners sense increased enemy activity soon. Upgrade your battle paddle."
		2:
			self.credits += 65
			prepare.intelligence = "Sources confirm that this isn't the best they can do. Remember that our walls can only take 2 hits before they collapse."
		3:
			self.credits += 75
			prepare.intelligence = "Our radars have detected unique activity patterns behind enemy lines. Be cautious, and save credits for future waves."
		4:
			self.credits += 100
			prepare.intelligence = "Their enemy paddles resemble our own. Sending projectiles back might not be enough, but we can blow them up on sight. Grab some lead."
		5:
			self.credits += 100
			prepare.intelligence = "Watch out for those drones. The paddle can withstand the blow, but it consumes our thrust power. Better shoot them down before they strike."
		6:
			self.credits += 110
			prepare.intelligence = "A spy has entered our city and damaged our walls from inside. It might not resist an onslaught."
		_:
			self.credits += 500
			prepare.intelligence = "«A letter from the president:» Our network has been breached. The intel department is unreachable. Use all our funds and be prepared for the worst."

	prepare.credits = self.credits
	return prepare

func _configure_paddle(paddle):
	paddle.has_gun = upgrade_status["gun"] == 1
	paddle.get_node("GunRecoilTimer").wait_time = {
		0: 0.9,
		1: 0.6,
		2: 0.4,
		3: 0.25,
	}[upgrade_status["gun_rate"]]
	paddle.max_speed = {
		0: 200,
		1: 280,
		2: 360,
		3: 460,
		4: 700,
	}[upgrade_status["speed"]]
	paddle.move_acceleration = {
		0: 500,
		1: 800,
		2: 1500,
		3: 2500,
		4: 4000,
	}[upgrade_status["stability"]]
	paddle.move_decay = paddle.move_acceleration - 50
	paddle.stun_vulnerability = {
		0: 1,
		1: 0.5,
		2: 0.25,
	}[upgrade_status["resistance"]]
	paddle.length = {
		0: 36,
		1: 44,
		2: 58,
		3: 66,
		4: 76,
	}[upgrade_status["length"]]

func _configure_wave(wave):
	# this is called after already having configure the paddle
	var emitter = wave.get_node("emitter")
	# ball emitter
	var ball_emitter = emitter.get_node("BallEmitter")
	ball_emitter.emission_period = {
		1: 2.4,
		2: 2.0,
		3: 1.25,
		4: 1.8,
		5: 1.75,
		6: 1.7,
		7: 1.7,
		8: 1.2,
	}[wave_num]
	ball_emitter.emission_time_variance_range = {
		1: 0.25,
		2: 0.4,
		3: 0.35,
		4: 0.35,
		5: 0.4,
		6: 0.35,
		7: 0.2,
		8: 0.05,
	}[wave_num]
	
	ball_emitter.emitted_speed = {
		1: 170,
		2: 200,
		3: 220,
		4: 200,
		5: 210,
		6: 210,
		7: 210,
		8: 280,
	}[wave_num]
	
	# emergency mode only exists from wave 2
	if wave_num >= 8:
		wave.get_node("EmergencyTimer").wait_time = 36
		# make last wave longer
		wave.get_node("TimeoutTimer").wait_time = 76
	elif wave_num >= 7:
		wave.get_node("EmergencyTimer").wait_time = 38
	elif wave_num >= 3:
		wave.get_node("EmergencyTimer").wait_time = 42.9
	else:
		wave.get_node("EmergencyTimer").wait_time = 99999
	
	if wave_num == 7:
		# damaged base
		wave.get_node("base").damaged = 1
	
	# enemy paddle emission
	var enemypaddle_emitter = emitter.get_node("EnemyPaddleEmitter")
	if wave_num >= 4:
		enemypaddle_emitter.total_enemies_to_emit = 1
		enemypaddle_emitter.emission_period = {
			4: 43,
			5: 30,
			6: 20,
			7: 10,
			8: 3
		}[wave_num]
		enemypaddle_emitter.emitted_speed = {
			4: 90,
			5: 100,
			6: 120,
			7: 150,
			8: 200,
		}[wave_num]
	else:
		enemypaddle_emitter.total_enemies_to_emit = 0

	# drone emission
	var barrier_emitter = emitter.get_node("BarrierEmitter")
	if wave_num >= 5:
		barrier_emitter.total_enemies_to_emit = {
			5: 6,
			6: 50,
			7: 50,
			8: 50,
		}[wave_num]
		barrier_emitter.emission_period = {
			5: 20,
			6: 20,
			7: 18,
			8: 9,
		}[wave_num]
		barrier_emitter.emitted_speed = {
			5: 85,
			6: 90,
			7: 100,
			8: 150,
		}[wave_num]
	else:
		barrier_emitter.total_enemies_to_emit = 0

	# drone emission
	var drone_emitter = emitter.get_node("DroneEmitter")
	if wave_num >= 5:
		drone_emitter.total_enemies_to_emit = {
			5: 1,
			6: 3,
			7: 4,
			8: 6,
		}[wave_num]
		drone_emitter.emission_period = {
			5: 42,
			6: 13,
			7: 22,
			8: 16,
		}[wave_num]
		drone_emitter.emitted_speed = {
			5: 320,
			6: 330,
			7: 340,
			8: 360,
		}[wave_num]
		drone_emitter.emitted_arg1 = {
			5: 18,
			6: 16,
			7: 16,
			8: 8,
		}[wave_num]
	else:
		drone_emitter.total_enemies_to_emit = 0

