extends Area2D

func _ready():
	body_entered.connect(func(b: Node2D):
		if b.is_in_group("player"):
			b.take_damage(false, global_position, "spikes")
	)
