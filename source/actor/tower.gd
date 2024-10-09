extends Node2D
class_name Tower

@onready var sprite_tower: Sprite2D = get_node_or_null("SpriteTower")
@onready var area_2d: Area2D = $Area2D
@onready var fort: Node2D = $Fort
@onready var audio_explosion: AudioStreamPlayer = $AudioExplosion

var _enemis : Array = []

@export var P_BULLET : PackedScene = preload("res://source/actor/bullet.tscn")
@export var bullet_count : int = 1
@onready var _current_bullet_count : int = bullet_count
@export var cooldown : float = 0.2
var _current_cd : float = 0
@export var damage : float = 10
## 防御塔摆放消耗
@export var cost : int = 10

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if _enemis.is_empty() : return
	var enemy = _enemis[0]
	if is_instance_valid(enemy):
		fort.look_at(enemy.global_position)
	else:
		_enemis.remove_at(0)
	# 判断冷却时间，攻击敌人
	if _current_cd > 0:
		# 进入冷却
		_current_cd -= delta
	else:
		_attack_enemy()

## 初始化方法
func initialize() -> void:
	area_2d.area_entered.connect(
		func(area: Area2D) -> void:
			_enemis.append(area.owner)
	)
	area_2d.area_exited.connect(
		func(area: Area2D) -> void:
			_enemis.erase(area.owner)
	)
	for area in area_2d.get_overlapping_areas():
		_enemis.append(area.owner)

## 攻击敌人
func _attack_enemy() -> void:
	if _enemis.is_empty() : return
	if _current_bullet_count <= 0 : 
		_current_bullet_count = bullet_count
		_current_cd = cooldown
	else :
		_spawn_bullet(_enemis[0])

## 生成子弹
func _spawn_bullet(enemy) -> void:
	var bullet = P_BULLET.instantiate()
	bullet.damage = damage
	add_child(bullet)
	bullet.initialize(enemy)
	_current_bullet_count -= 1
	audio_explosion.play()

## 当前金币数量是否足够摆放
func can_place_tower(coin : int) -> bool:
	return coin - cost >= 0 
