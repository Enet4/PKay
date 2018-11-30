extends StaticBody2D

signal damage

export (int) var damaged = 0

func _ready():
	self._update_sprites()

func _on_wall_area_entered( area ):
	if area.get_parent().get_name() == "PlainBall":
		# TODO ball hit the base, damage and destroy ball
		area.blow_up()

func _on_touch_Drone(drone):
	drone.blow_up()


func _on_base_damage():
	damaged += 1
	
	self._update_sprites()
	
	if self.damaged >= 3:
		$AudioDestroy.play()
		$collision.disabled = true
		$"..".emit_signal("game_over")
	else:
		$AudioDamage.play()

func _update_sprites():
	$base1.hide()
	$base2.hide()
	$base3.hide()
	$forcefield.hide()
	$"forcefield/animation".stop()
	if self.damaged <= 0:
		$base1.show()
		if self.damaged < 0:
			$forcefield.show()
			$"forcefield/animation".play("default")
	else:
		match self.damaged:
			1: 
				$base2.show()
			2: 
				$base3.show()
