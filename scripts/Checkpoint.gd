extends Area2D
var used:bool=false
@onready var anim:AnimatedSprite2D=$AnimatedSprite2D if has_node("AnimatedSprite2D") else null
signal checkpoint_reached
func _ready(): body_entered.connect(_on_body)
func _on_body(body:Node2D):
	if body.is_in_group("player") and not used:
		used=true; emit_signal("checkpoint_reached")
		AudioMgr.crystal()  # reuse crystal sound
		if anim: anim.modulate=Color(0.3,1,0.3)
