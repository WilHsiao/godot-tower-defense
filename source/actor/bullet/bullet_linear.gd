extends Bullet
class_name BulletLinear

const EXPLOTION = preload("res://source/actor/explotion.tscn")
var _target_position
var direction : Vector2
var is_explote : bool = false

func _ready() -> void:
	var tween : Tween = create_tween()
	tween.tween_callback(queue_free).set_delay(1)
	super()

func _process(delta: float) -> void:
	if is_explote:
		return
	var step = speed * delta
	position += direction * step

func initialize(target : Enemy) -> void:
	super(target)
	_target_position = target.global_position
	direction = (_target_position - global_position).normalized()
	rotation = direction.angle()

func spawn_explotion() -> Explotion:
	var explotion : Explotion = EXPLOTION.instantiate()
	explotion.damage = damage * 0.8
	add_child(explotion)
	is_explote = true
	return explotion

func attack(enemy : Enemy) -> void:
	var explotion = spawn_explotion()
	await explotion.exploted
	if is_instance_valid(enemy):
		super(enemy)
