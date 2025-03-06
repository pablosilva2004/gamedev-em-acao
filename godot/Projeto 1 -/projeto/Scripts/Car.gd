extends StaticBody2D

@onready var _animatedSprite = $SpriteAnimated

var _isReversed = false

func _process(_delta):
	if !_animatedSprite.is_playing():
		if Input.is_action_just_pressed("Carro_AbrirCapo"):
			_toggleAnimation()

func _toggleAnimation() -> void:
	if _isReversed:
		_animatedSprite.play("abrindo_capo")
	else:
		_animatedSprite.play("abrindo_capo", -1.0)
		
	_isReversed = !_isReversed
