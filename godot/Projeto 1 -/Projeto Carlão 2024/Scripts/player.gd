extends CharacterBody2D

@export_category("Variáveis do Player")
@export var _moveSpeed: float = 64.0 
const _ACCELERATION: float = 0.1 # Suavidade de movimento: (0, _ACCELERATION, 1)
const _FRICTION: float = 0.1 # Suavidade de parada: (1, _FRICTION, 0)

@export_category("Animação")
@export var _animationTree: AnimationTree = null
var _stateMachine 

func _ready() -> void:
	_stateMachine = _animationTree["parameters/playback"] # Recebe o reprodutor de animações

func _process(_delta: float) -> void:
	_move()
	_animate()
	move_and_slide()
	
func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("Player_Esquerda", "Player_Direita"),
		Input.get_axis("Player_Cima", "Player_Baixo")
	)
	
	if _direction != Vector2.ZERO: # Andando
		_animationTree["parameters/idle/blend_position"] = _direction # Vai definir a direção da animação Idle
		_animationTree["parameters/walk/blend_position"] = _direction # Vai definir a direção da animação Walk
		velocity = lerp(velocity, _direction.normalized() * _moveSpeed, _ACCELERATION) # Aplica o movimento suave
		return
	
	velocity = lerp(velocity, _direction.normalized() * _moveSpeed, _FRICTION) # Aplica a parada suave

func _animate() -> void:
	if velocity.length() > 5: # Andando
		_stateMachine.travel("walk") # Chama a animação walk de acordo com a sua direção
		return
	
	_stateMachine.travel("idle") # Chama a animação idle de acordo com a sua direção

"""
Código escrito por SN4KE
Código criado por DevBandeira
	Link movimento do personagem: https://youtu.be/IH640VnpF9w?si=HPzZad-3S2dAW3Gb
	Link aplicando as animações: https://youtu.be/U3CWa1IgQPw?si=2TSUSwbuhzoNNej9
"""
