extends PathFollow2D
class_name Enemy

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var area_2d: Area2D = %Area2D
#@onready var audio_die: AudioStreamPlayer = %audio_die

@export var speed : float = 120
@export var max_hp : float = 100
@onready var current_hp : float = max_hp : 
	set(value):
		current_hp = value
		progress_bar.value = value
		if current_hp < max_hp and not progress_bar.visible:
			progress_bar.show()
		if current_hp <= 0:
			_die()
@export var attack : float = 10
## 击杀时候获得的金币数量
@export var loot_coin : int = 10

signal damaged
signal died

func _ready() -> void:
	progress_bar.max_value = max_hp
	progress_bar.hide()

func _process(delta: float) -> void:
	progress += speed * delta
	sprite_2d.rotation = rotation
	rotation = 0
	if progress_ratio >= 0.99:
		damage()
		queue_free()
		get_parent().remove_child(self)

## 受到伤害
func hit(damage : float) -> void:
	current_hp -= damage

## 造成伤害
func damage() -> void:
	damaged.emit(attack)

## 角色死亡
func _die() -> void:
	died.emit()
	#audio_die.play()
	queue_free()
