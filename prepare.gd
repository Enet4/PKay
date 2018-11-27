extends Node

export (int) var credits
export (int) var wave_num
export (String) var intelligence = "To barrel roll, press Z or R twice."

export (Dictionary) var status


func _ready():
	# Initialization here
	self._update_credits()
	$"margin/vbox/LblHeader".text = "Prepare for wave " + str(self.wave_num + 1)
	$"margin/vbox/margin/grid/upgrade_speed".grab_focus()
	$"margin/vbox/LblIntel".text = self.intelligence
	
	for k in status.keys():
		var upgrade_id = "upgrade_" + k
		print("Initializing ", upgrade_id)
		var upgrade = $"margin/vbox/margin/grid".get_node(upgrade_id)
		upgrade.set_level(status[k])
	
	# hide upgrades still not available
	if self.wave_num < 2:
		$"margin/vbox/margin/grid/upgrade_forcefield".hide()
	if self.wave_num < 3:
		$"margin/vbox/margin/grid/upgrade_gun".hide()
	if self.wave_num < 4:
		$"margin/vbox/margin/grid/upgrade_gun_rate".hide()
		$"margin/vbox/margin/grid/upgrade_resistance".hide()


func pay(ncredits):
	if self.credits < ncredits:
		return false
	self.credits -= ncredits
	self._update_credits()
	return true


func _update_credits():
	$"margin/vbox/LblCredits".text = "Credits: " + str(self.credits)


func _on_upgrade_request_purchase(upgrade, next_level, price):
	if self.pay(price):
		status[upgrade.upgrade_id] = next_level
		upgrade.emit_signal('change_level', next_level)


func _on_BtnNext_pressed():
	get_parent().open_wave()
