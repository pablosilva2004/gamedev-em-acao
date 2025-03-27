extends CharacterBody2D

# Constantes para controle do movimento e suavidade
const _ACCELERATION : float = 0.12   # Suavidade de movimento, controlando o embalo
const _FRICTION : float = 0.12       # Suavidade de parada, controlando a frenagem

# Probabilidade de piscar (% de chance aleatória)
const _BLINK_PROBABILITY  : float = 0.25   # Probabilidade de piscada para Idle e Walk
const _BLINK_MIN_INTERVAL : float = 0.9  # Intervalo mínimo para piscada (em segundos)
const _BLINK_MAX_INTERVAL : float = 1.1  # Intervalo máximo para piscada (em segundos)

# Categorias controláveis via Inspector
@export_category("Variables")
@export var _moveSpeed : float = 95.0   # Velocidade de movimento do personagem

@export_category("Animations")
@export var _animationTree : AnimationTree = null   # Árvore de animações (AnimationTree) para controle das animações

# Variáveis internas
var _blinkTimer : float = 0.0  # Timer para controlar o intervalo de piscada

# Função que é chamada a cada frame do jogo (geralmente 60 vezes por segundo)
func _physics_process(_delta: float) -> void:
	_move()            # Chama a função para processar o movimento do personagem
	_animate()         # Chama a função para processar as animações
	move_and_slide()   # Move o personagem com a física aplicada (desliza conforme a movimentação)

	# Atualiza o temporizador para alternar a piscada
	_blinkTimer -= _delta

# Função para controlar o movimento do personagem
func _move():
	# Em jogos TopDown, o personagem se move em até 8 direções no plano X/Y
	var _direction : Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"), # Eixo X (movimento horizontal)
		Input.get_axis("move_up", "move_down")     # Eixo Y (movimento vertical)
	)
	
	# Se o jogador estiver se movendo
	if _direction != Vector2.ZERO:
		# Atualiza a direção do personagem para as animações de idle e walk, dependendo da direção
		_animationTree["parameters/idle/blend_position"] = _direction
		_animationTree["parameters/idle_blink/blend_position"] = _direction
		_animationTree["parameters/walk/blend_position"] = _direction
		_animationTree["parameters/walk_blink/blend_position"] = _direction
		
		# Aplica a interpolação de aceleração para suavizar o movimento do personagem
		velocity = lerp(velocity, _direction.normalized() * _moveSpeed, _ACCELERATION)
		_animationTree.set("parameters/final_move_transition/transition_request", "state_walk")  # Transição para walk
		return
	
	# Se não estiver se movendo, aplica a interpolação de fricção para suavizar a parada
	velocity = lerp(velocity, _direction.normalized() * _moveSpeed, _FRICTION)
	_animationTree.set("parameters/final_move_transition/transition_request", "state_idle")  # Transição para idle

# Função para gerenciar as animações do personagem
func _animate() -> void:
	# Verifica se o personagem está se movendo
	var isMoving = velocity.length() > 20
	
	# Se o personagem está se movendo, executa a animação de andar
	if isMoving:
		# Alternância aleatória entre a animação de Walk normal ou Walk com piscada
		if _blinkTimer <= 0:
			if randf() < _BLINK_PROBABILITY:
				_animationTree.set("parameters/walk_final_blend/blend_amount", 1)  # Walk com piscada
			else:
				_animationTree.set("parameters/walk_final_blend/blend_amount", 0)  # Walk normal
			_blinkTimer = randf_range(_BLINK_MIN_INTERVAL, _BLINK_MAX_INTERVAL)  # Resetando o timer com intervalo aleatório
		return
	
	# Se o personagem não está se movendo, executa a animação de idle
	# Alternância aleatória entre a animação de Idle normal ou Idle com piscada
	if _blinkTimer <= 0:
		if randf() < _BLINK_PROBABILITY:
			_animationTree.set("parameters/idle_final_blend/blend_amount", 1)  # Idle com piscada
		else:
			_animationTree.set("parameters/idle_final_blend/blend_amount", 0)  # Idle normal
		_blinkTimer = randf_range(_BLINK_MIN_INTERVAL, _BLINK_MAX_INTERVAL)  # Resetando o timer com intervalo aleatório



'''

Créditos dos materiais utilizados para os estudos

RPG TopDown - Godot 4.0
 https://www.youtube.com/playlist?list=PLFzAtSiFUbT-UZcEli_IlKFQdk3FEBMlq

Godot 4 Animation Tree: Combining Animations Tutorial
 https://www.youtube.com/watch?v=dbBG_LM4dwI

'''
