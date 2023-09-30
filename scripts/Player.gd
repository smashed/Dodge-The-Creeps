extends CharacterBody2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var target = position

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	get_node("EnemyCollision/CollisionShape2D").disabled = true

func _physics_process(delta):
	#up_direction = Vector2(0,0)
	key_movement()
	mouse_movement(delta)
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.length() || Input.is_action_pressed("Click"):
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	move_and_slide()
	
func mouse_movement(delta):
	if Input.is_action_pressed("Click"):
		target = get_global_mouse_position()
	if velocity.length() == 0:
		position = position.move_toward(target, speed * delta)
		look_at(target)
	
func key_movement():
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	velocity = direction * speed
	look_at(velocity + position)
	if direction:
		target = position

func start(pos):
	position = pos
	show()
	get_node("EnemyCollision/CollisionShape2D").disabled = false

func _on_enemy_collision_body_entered(body):
	if body.is_in_group("mobs"):
		hide() # Player disappears after being hit.
		hit.emit()
		# Must be deferred as we can't change physics properties on a physics callback.
		get_node("EnemyCollision/CollisionShape2D").set_deferred("disabled", true)
