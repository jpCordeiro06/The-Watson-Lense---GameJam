extends Area2D

signal evidencia_escaneada(id_da_pista)

@export var id_da_pista: String = "pista_generica"
@export var nome_evidencia: String = "Evidência"
@export var sprite_icone: Texture2D
@export var analise_holmes: String = "Análise pendente..."

var player_in_range: CharacterBody2D = null

func _ready():
	modulate.a = 0.7

func scan():
	print("Evidência '", id_da_pista, "' foi escaneada!")
	
	# Emitir sinal para o diálogo (sistema antigo)
	emit_signal("evidencia_escaneada", id_da_pista)
	
	# NOVO: Adicionar ao QuadroEvidencias
	if has_node("/root/QuadroEvidencias"):
		var quadro = get_node("/root/QuadroEvidencias")
		
		# Usar sprite do próprio nó se não tiver ícone customizado
		var icone = sprite_icone
		if icone == null and has_node("Sprite2D"):
			icone = $Sprite2D.texture
		
		quadro.adicionar_evidencia(
			id_da_pista,
			nome_evidencia,
			icone,
			analise_holmes
		)
		print("✓ Evidência adicionada ao quadro!")
	else:
		print("⚠ QuadroEvidencias não encontrado como Autoload!")
	
	# Desabilitar colisão e diminuir opacidade
	$CollisionShape2D.set_deferred("disabled", true)
	modulate.a = 0.4

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = body
		modulate.a = 1.0

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = null
		modulate.a = 0.7
