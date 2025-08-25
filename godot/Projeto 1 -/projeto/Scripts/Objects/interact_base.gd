extends Area2D

'''
Define os tipos de interação possíveis para o objeto:
  DEFAULT: interação genérica
  COLLECTABLE: item coletável
  DIALOGUE: inicia um diálogo
'''

enum InteractionType { DEFAULT, COLLECTABLE, DIALOGUE }

# Tipo de interação que este objeto representa
@export var interaction_type: InteractionType = InteractionType.DEFAULT

# Textura exibida no Sprite do objeto, pode ser definida no editor
# Ao ser modificada, chama o setter 'set_sprite_texture' para atualizar visualmente
@export var sprite_texture: Texture2D : set = set_sprite_texture

# Define se o objeto será destruído (removido da cena) após a interação
@export var destroy_after_interaction: bool = false

# Referência ao node Sprite2D, usado para exibir a textura
@onready var sprite: Sprite2D = $Sprite

# Setter que atualiza visualmente a textura do objeto
func set_sprite_texture(value):
	sprite_texture = value
	if sprite:
		sprite.texture = value

# Chamado quando o objeto entra na cena
# Garante que a textura seja aplicada corretamente no runtime
func _ready():
	set_sprite_texture(sprite_texture)

# Executa a interação com o jogador, dependendo do tipo definido
func execute_interaction(player):
	print("Interagiu com: ", interaction_type)
	
	match interaction_type:
		InteractionType.DEFAULT:
			print("Nada definido para esse objeto...")
		
		InteractionType.COLLECTABLE:
			# Coleta o objeto
			if player.has_method("collect_item"):
				player.collect_item(self)
			else:
				print("Jogador não possui a função 'collect_item'!")
		
		InteractionType.DIALOGUE:
			# Inicia um diálogo
			if player.has_method("start_dialogue"):
				player.start_dialogue()
			else:
				print("Função 'start_dialogue' não encontrada no jogador...")
	
	# Remove o objeto da cena após a interação, se estiver ativado
	if destroy_after_interaction:
		queue_free()
