extends Node2D
class_name Explotion

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D

var damage : float = 10

signal exploted

func _ready() -> void:
	create_tween().tween_callback(_explote).set_delay(0.5)

## 爆炸
func _explote() -> void:
	for area : Area2D in area_2d.get_overlapping_areas():
		area.owner.hit(damage)
	queue_free()
	get_parent().remove_child(self)
	exploted.emit()
