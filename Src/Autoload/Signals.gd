extends Node

signal hit
signal charge
signal release_laser
signal boss_death
signal boss_death_stomp

func signal_hit():
	emit_signal("hit")

func signal_charge():
	emit_signal("charge")

func signal_release_laser():
	emit_signal("release_laser")

func signal_boss_death():
	emit_signal("boss_death")

func signal_boss_death_stomp():
	emit_signal("boss_death_stomp")
