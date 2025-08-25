extends CharacterBody2D

# Referências aos nodes de interação
@onready var _interactionRay : RayCast2D = $Interaction/InteractionRay
@onready var _interactionLabel : Label = $Interaction/InteractionLabel

# Constantes para controle do movimento e suavidade
const _ACCELERATION : float = 0.12   # Suavidade de movimento, controlando o embalo
const _FRICTION : float = 0.12       # Suavidade de parada, controlando a frenagem

# Probabilidade de piscar (% de chance aleatória)
const _BLINK_PROBABILITY  : float = 0.25 # Probabilidade de piscada para Idle e Walk
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
	_move()                # Chama a função para processar o movimento do personagem
	_animate()             # Chama a função para processar as animações
	_handle_interaction()  # Chama a função para habilitar as interações
	move_and_slide()       # Move o personagem com a física aplicada (desliza conforme a movimentação)
	
	# Atualiza o temporizador para alternar a piscada
	_blinkTimer -= _delta

# Função para controlar o movimento do personagem
func _move():
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
		
		# Atualiza a direção do RayCast para a direção onde o player está se movendo
		_interactionRay.target_position = _direction.normalized() * 50
		
		# Aplica a interpolação de aceleração para suavizar o movimento do personagem
		velocity = lerp(velocity, _direction.normalized() * _moveSpeed, _ACCELERATION)
		_animationTree.set("parameters/final_move_transition/transition_request", "state_walk")
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
			_blinkTimer = randf_range(_BLINK_MIN_INTERVAL, _BLINK_MAX_INTERVAL)    # Resetando o timer com intervalo aleatório
		return
	
	# Se o personagem não está se movendo, executa a animação de idle
	# Alternância aleatória entre a animação de Idle normal ou Idle com piscada
	if _blinkTimer <= 0:
		if randf() < _BLINK_PROBABILITY:
			_animationTree.set("parameters/idle_final_blend/blend_amount", 1)  # Idle com piscada
		else:
			_animationTree.set("parameters/idle_final_blend/blend_amount", 0)  # Idle normal
		_blinkTimer = randf_range(_BLINK_MIN_INTERVAL, _BLINK_MAX_INTERVAL)    # Resetando o timer com intervalo aleatório

# Função para detectar objetos interativos e lidar com a interação do jogador
func _handle_interaction():
	if _interactionRay.is_colliding(): # Verifica se o RayCast está colidindo com algum objeto na direção que o player está olhando
		var collider = _interactionRay.get_collider() # Obtém o node (objeto) com o qual o RayCast está colidindo
		
		# Verifica se o objeto colidido é um Area2D e se possui a função "execute_interaction"
		# Isso garante que o objeto é interativo e pode responder à interação do jogador
		if collider is Area2D and collider.has_method("execute_interaction"):
			# Torna visível a label de interação acima do personagem, notificando que a interação é permitida
			_interactionLabel.visible = true
			
			# Verifica se o jogador apertou o botão de interação no frame atual
			if Input.is_action_just_pressed("interact"):
				# Executa a função "execute_interaction" no objeto interativo
				# O próprio Player é passado como parâmetro, permitindo que o objeto saiba quem interagiu
				collider.execute_interaction(self)
			return
	
	# Se o RayCast não estiver colidindo com um objeto interativo, oculta a label de interação
	_interactionLabel.visible = false



'''

Créditos dos materiais utilizados para os estudos

RPG TopDown - Godot 4.0
 https://www.youtube.com/playlist?list=PLFzAtSiFUbT-UZcEli_IlKFQdk3FEBMlq

Godot 4 Animation Tree: Combining Animations Tutorial
 https://www.youtube.com/watch?v=dbBG_LM4dwI

'''
