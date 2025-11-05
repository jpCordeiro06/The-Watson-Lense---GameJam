class_name Watson extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var move_speed: float = 250.0
var can_move: bool = true
var state: String = "idle"

@onready var interaction_area: Area2D = $InteractionArea
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var game_director = get_tree().current_scene

func _ready():
	pass

func _physics_process(delta: float) -> void:
	
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	
	velocity = direction * move_speed
	
	if setState() == true || setDirection() == true:
		updateAnimation()
	
	if can_move:
		var direction : Vector2 = Input.get_vector("left", "right", "up", "down")
		velocity = direction * move_speed
	else:
		# Se não puder se mover, garante que a velocidade seja zero
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	handle_interaction()


func setDirection() -> bool:
	var new_dir: Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false
	
	if direction.y == 0:
		new_dir = Vector2.RIGHT if direction.x < 0 else Vector2.LEFT
	elif direction.x ==0: 
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_dir == cardinal_direction:
		return false
	cardinal_direction = new_dir
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true


func setState() -> bool:
	var new_state: String = "Idle" if direction == Vector2.ZERO else "walk"
	if new_state == state:
		return false
	state = new_state
	return true
	

func updateAnimation() -> void:
	animation_player.play(state + "_" + aniDirection())
	pass
	
	
func aniDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func handle_interaction():
	if Input.is_action_just_pressed("interact"):
		print("Tecla 'E' pressionada!")
		var areas = $InteractionArea.get_overlapping_areas()
		print("Tecla 'E' pressionada! Áreas encontradas: ", areas.size())

		for area in areas:
			# 1. VERIFICAÇÃO ESPECIAL: É O CADEADO?
			if area.id_da_pista == "cadeado_quarto":
				print("Interagindo com o CADEADO.")

				# Verifica se o Diretor (Quarto.gd) tem a função antes de chamar
				if game_director.has_method("abrir_ui_cadeado"):
					game_director.abrir_ui_cadeado()

				return # Para a interação aqui.

			# 2. INTERAÇÃO PADRÃO: É UMA EVIDÊNCIA ESCANEÁVEL?
			if area.has_method("scan"):
				print("Interagindo com EVIDÊNCIA normal.")
				area.scan()
				return # Para a interação aqui.

func travar_movimento(travado: bool):
	# Se 'travado' for true, o jogador não pode se mover. Se for false, ele pode.
	can_move = not travado
