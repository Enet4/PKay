extends Node

const TITLE_SCENE = preload("res://title.tscn")
const WAVE_SCENE = preload("res://wave.tscn")
const PREPARATION_SCENE = preload("res://prepare.tscn")

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
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func exit_game():
	self.get_tree().quit()


func new_game():
	score = 0
	wave_num = 0
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
	# TODO configure stuff
	# - paddle configurations based on upgrades
	_configure_paddle(wave.get_node("Paddle"))
	# - base configuration based on upgrades
	wave.get_node("base").damaged = {
		0: 0,
		1: -1,
		2: -2,
	}[upgrade_status["forcefield"]]
	# - wave configurations based on level

	# transfer the current score
	wave.score = score
		
	# remove other scenes
	for scn in get_children():
		scn.queue_free()
	# add wave scene
	self.add_child(wave)

func next_phase():
	if self.num_wave < 10:
		self.open_preparation()
	else:
		self.open_ending()

func open_preparation():
	for child in self.get_children():
		child.queue_free()
	var prepare = self._new_prepare_scene()
	self.add_child(prepare)

func open_ending():
	# TODO
	pass

func _new_prepare_scene():
	var prepare = PREPARATION_SCENE.instance()
	prepare.status = self.upgrade_status
	prepare.wave_num = self.wave_num
	match self.wave_num:
		1:
			self.credits += 50
			prepare.intelligence = "We have ovecome the first attack, but our scanners sense increased enemy activity soon. Upgrade your battle paddle."
		2:
			self.credits += 75
			prepare.intelligence = "Sources confirm that this isn't the best they can do. Remember that our walls can only take 2 hits."
		3:
			self.credits += 90
			prepare.intelligence = "Our radars have detected unique activity patterns behind enemy lines. Be cautious, and save credits for future waves."
		4:
			self.credits += 120
			prepare.intelligence = "Their enemy paddles resemble our own. Sending projectiles back might not be enough, but we can blow them up on sight. Grab some heat."
		5:
			self.credits += 150
			prepare.intelligence = "Not even enemy paddles can surpass our wits. Keep up the good work, and stay sharp!"
		6:
			self.credits += 180
			prepare.intelligence = "Watch out for those drones. The paddle can withstand the blow, but it consumes our thrust power. Better shoot them down before they strike."
		6:
			self.credits += 220
			prepare.intelligence = "A spy has entered our city and damaged our walls from inside. It will not resist a single blow in this state! Be warned!"
		7:
			self.credits += 220
			prepare.intelligence = "We're in for a motherload of enemies this time. Take all you can acquire."
		_:
			self.credits += 1000
			prepare.intelligence = "Our information systems were breached. All our intel is gone. Be prepared for the worst."

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
		1: 300,
		2: 450,
		3: 600,
		4: 800,
	}[upgrade_status["speed"]]
	paddle.move_acceleration = {
		0: 500,
		1: 800,
		2: 1500,
		3: 2500,
	}[upgrade_status["stability"]]
	paddle.move_decay = paddle.move_acceleration - 50
	paddle.stun_vulnerability = {
		0: 1,
		1: 0.5,
		2: 0.25,
	}[upgrade_status["resistance"]]
	paddle.length = {
		0: 36,
		1: 48,
		2: 60,
		3: 74,
	}[upgrade_status["length"]]

