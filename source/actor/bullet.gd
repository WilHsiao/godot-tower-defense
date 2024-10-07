extends Node2D
class_name Bullet

@onready var area_2d: Area2D = $Area2D

## 子弹的移动速度
@export var speed : float = 400
var damage : float = 0
## 目标敌人节点的引用
var _target : Enemy= null

func _ready() -> void:
	area_2d.area_entered.connect(
		func(area : Area2D) -> void:
			if not area.owner is Enemy: return
			var enemy : Enemy = area.owner
			attack(enemy)
	)

func _process(delta: float) -> void:
	if not _target : 
		queue_free()
		return
	if _target and not _target.is_queued_for_deletion():
		var direction = (_target.global_position - global_position).normalized()
		rotation = direction.angle()
		position += direction * speed * delta
	else:
		queue_free()

## 初始化方法，设置当前的目标
func initialize(enemy : Enemy) -> void:
	_target = enemy

## 对敌人造成伤害
func attack(enemy : Enemy) -> void:
	enemy.hit(damage)
	queue_free()
