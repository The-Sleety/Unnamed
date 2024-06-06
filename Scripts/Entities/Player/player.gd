extends CharacterBody2D

class_name PlayerObj

@export var gravity = 980

@onready var oxygenText = $UI/OxyBar/Oxygen



@onready var playerSprite = $PlayerSprite
@onready var gunSprite = $Gun/Offset/GunSprite
@onready var offset = $Gun/Offset

@export_category("Player Status")
@export var speed = 300.0
@export var health = 100
@export var jumpPower = -400.0
@export var dashPower = 2000
@export var oxygenLevel : int = 100

var dashTime = 1.5
@export var fric = 10
var canMove = true
var canDash = true

var isDashing = false

var canPound = true
var isPounding = false
var justPounded

var canBreathe = playerGlobals.playerCanBreathe
var isInSpace = playerGlobals.playerInSpace


func _physics_process(delta):
	HandleJump(delta)
	HandleMovement(delta)
	flipWeapon()
	breathe(delta)
	updateLabels()
	updategravity()

func HandleJump(delta):
	
	if not is_on_floor():
		canPound = true
		canDash = false
		velocity.y += gravity * delta
		if Input.is_action_pressed("dash"):
			velocity.y = jumpPower * -2.5
			isPounding = true
	else:
		canDash = true
		canPound = false
	if is_on_floor() and !isPounding:
		canDash = true

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpPower
		if isPounding:
			velocity.y = jumpPower * 1.5
			await get_tree().create_timer(0.15).timeout
			isPounding = false
		
func HandleMovement(delta):
	var dir = Input.get_axis("left", "right")
	if dir:
		velocity.x = dir * speed
		if isDashing:
			velocity = Vector2i(dashPower * dir, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if Input.is_action_just_pressed("dash") and canDash:
		isDashing = true
		canDash = false
		$DashTimer.start()
		$DashAgainTimer.start()
	
	

	move_and_slide()
	
func flipWeapon():
	offset.look_at(get_global_mouse_position())
	if (self.global_position - get_global_mouse_position()).x < 0:
		offset.scale = Vector2(1, 1)
	else:
		offset.scale = Vector2(1, -1)

func breathe(delta):
	if !canBreathe and isInSpace:
		oxygenLevel -= 1 * delta
		if oxygenLevel <= 0:
			health -= 1
			if health <= 0: print("die()") 
	if canBreathe and !isInSpace:
		if oxygenLevel < 100:
			oxygenLevel += 1 

func shoot():
	pass

func updateLabels():
	oxygenText.text = str(oxygenLevel)
	
func updategravity():
	if playerGlobals.playerInSpace:
		gravity  = 480
	if !playerGlobals.playerInSpace:
		gravity = 980
	
func die():
	self.queue_free()

func _on_dash_timer_timeout():
	isDashing = false


func _on_dash_again_timer_timeout():
	canDash = true
