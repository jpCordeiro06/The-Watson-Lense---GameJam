extends Node2D

@onready var dialogo_ui = $DialogoUI/MeuPainel
@onready var jogador = $Watson
@onready var cadeado_ui = $CanvasLayerCadeado/CadeadoUI

const CODIGO_CORRETO = "3815"
var ultima_evidencia_interagida: String = ""
var gaveta_ja_vista: bool = false

func _ready():
	var jogador = get_tree().get_first_node_in_group("Player")
	
	if jogador and not Global.ponto_de_spawn_alvo.is_empty():
		var ponto_de_spawn = find_child(Global.ponto_de_spawn_alvo)
		
		if ponto_de_spawn:
			jogador.global_position = ponto_de_spawn.global_position
		else:
			print("AVISO: Ponto de spawn '", Global.ponto_de_spawn_alvo, "' não encontrado no Quarto!")
			
		Global.ponto_de_spawn_alvo = ""
	
	if dialogo_ui:
		dialogo_ui.dialogo_encerrado.connect(_on_dialogo_encerrado)
	
	if cadeado_ui != null:
		cadeado_ui.codigo_inserido.connect(_on_codigo_inserido)
	else:
		print("AVISO: UI do cadeado não encontrada no Quarto!")
	
	# Conectar evidências que estão no QUARTO
	if has_node("EvidenciaGavetaCadeado"):
		$EvidenciaGavetaCadeado.evidencia_escaneada.connect(_on_evidencia_escaneada)
		
	if has_node("EvidenciaNotaFiscal"):
		$EvidenciaNotaFiscal.evidencia_escaneada.connect(_on_evidencia_escaneada)

func _on_porta_para_apartamento_body_entered(body):
	if body.is_in_group("Player"):
		Global.ponto_de_spawn_alvo = "PontoDeEntradaSala"
		get_tree().change_scene_to_file("res://cenas/Sala.tscn")

var dialogos = {
	"nota_fiscal": {
		"analise_holmes": "Análise: Uma transação para um componente eletrônico obsoleto, no valor de **$25**. O comprador é a vítima. A compra de tecnologia antiga é um padrão emergente neste caso.",
		"opcoes": [
			{"texto": "Anotado. Um valor... peculiar.", "resposta_holmes": "Concordo. A precisão do valor sugere importância."},
			{"texto": "O que era o componente?", "resposta_holmes": "Um capacitor de fluxo temporal de baixa potência. Inútil para qualquer tecnologia moderna. A não ser..."}
		]
	},
	"gaveta_cadeado": {
		"analise_holmes": "Análise: Este é um cadeado de combinação analógico, uma anomalia neste apartamento. A tecnologia é arcaica, mas eficaz. Não consigo interfacear. Você terá que encontrar a combinação, Watson.",
		"opcoes": [
			{"texto": "Procurar por números escritos por perto.", "resposta_holmes": "Lógico. A memória humana é falha; anotações são comuns."},
			{"texto": "Examinar o diário da vítima.", "resposta_holmes": "Uma boa hipótese. Datas ou eventos significativos são frequentemente usados como senhas."},
			{"texto": "Ignorar o cadeado por enquanto.", "resposta_holmes": "Ineficiente, mas é sua prerrogativa. Prossiga."}
		]
	},
	"corpo_vitima": {
		"analise_holmes": "Análise: Biometria completa. Causa da morte: parada cardiorrespiratória. Contudo, detecto um resíduo de partícula quântica em seu relógio. Não é a causa da morte, mas é... peculiar.",
		"opcoes": [
			{"texto": "O que é essa partícula?", "resposta_holmes": "Origem desconhecida. Anomalia de alta prioridade. Precisamos de mais dados."},
			{"texto": "Examinar o corpo mais de perto.", "resposta_holmes": "Ação recomendada. Procure por modificações ou marcas incomuns."},
			{"texto": "Focar na causa da morte.", "resposta_holmes": "Morte por parada cardíaca. A parada cardíaca pode ter sido induzida. Procure por possíveis causadores."}
		]
	},
	"porta_retrato": {
		"analise_holmes": "Análise: Um quadro. A imagem mostra o por do sol. Metadados indicam a data do evento: **18** de Outubro. Relevância desconhecida, mas anomalias temporais são significativas.",
		"opcoes": [
			{"texto": "Anotado. Procurar mais números.", "resposta_holmes": "Eficiente. Continue a varredura."},
			{"texto": "Tem mais alguma coisa na foto?", "resposta_holmes": "Reconhecimento... negativo."}
		]
	}
}

func iniciar_dialogo(id_da_pista: String):
	var dialogos = dialogos.get(id_da_pista)
	
	if dialogos != null and dialogo_ui != null:
		jogador.travar_movimento(true)
		dialogo_ui.start_dialogue(dialogos)

func _on_evidencia_escaneada(id_da_pista):
	ultima_evidencia_interagida = id_da_pista
	
	if id_da_pista == "gaveta_cadeado":
		if not gaveta_ja_vista:
			# 1. Primeira vez? Mostra o diálogo.
			iniciar_dialogo(id_da_pista)
		else:
			# 2. Próximas vezes? Abre o cadeado direto.
			print("Gaveta já vista. Abrindo cadeado diretamente.")
			abrir_ui_cadeado()
	else:
		# Para todas as outras evidências, apenas mostre o diálogo.
		iniciar_dialogo(id_da_pista)
	var nome_pista = id_da_pista.replace("_", " ").capitalize()
	var sprite_pista = load("res://assets/icones_evidencias/" + id_da_pista + ".png")
	
	# Envia o dicionário completo
	QuadroEvidencias.adicionar_evidencia(id_da_pista, nome_pista, sprite_pista, dialogos)
	
func _on_dialogo_encerrado():
	if jogador:
		jogador.travar_movimento(false)
	
	# Se o diálogo que acabou foi o da gaveta...
	if ultima_evidencia_interagida == "gaveta_cadeado":
		gaveta_ja_vista = true # Marca como vista
		abrir_ui_cadeado() # Abre o cadeado
	
	ultima_evidencia_interagida = ""

func abrir_ui_cadeado():
	if cadeado_ui != null:
		cadeado_ui.mostrar()
		get_tree().paused = true
	else:
		print("ERRO: Não foi possível abrir a UI do cadeado no Quarto!")
func _on_codigo_inserido(codigo_tentado: String):
	if codigo_tentado == CODIGO_CORRETO:
		print("CÓDIGO CORRETO! Finalizando o protótipo.")
		
		# 1. Despausar o jogo
		get_tree().paused = false
		
		# 2. Esconder a UI do cadeado
		if cadeado_ui:
			cadeado_ui.hide()
		
		# 3. Mostrar mensagem final de HOLMES
		if dialogo_ui:
			dialogo_ui.mostrar_dialogo("HOLMES: Excelente trabalho dedutivo, Watson. O cadeado está aberto. Nossa investigação pode continuar...")
		
		# 4. Aguardar 4 segundos para o jogador ler
		await get_tree().create_timer(4.0).timeout
		
		# 5. Ir para a cena de fim (CORRIGIDO - apenas uma chamada)
		get_tree().change_scene_to_file("res://cenas/Fim.tscn")
		
	else:
		# ❌ CÓDIGO INCORRETO
		print("Código incorreto.")
		
		# Feedback visual no título
		var titulo_label = cadeado_ui.get_node_or_null("VBoxContainer/TitleBar/TituloLabel")
		if titulo_label:
			titulo_label.text = "COMBINAÇÃO INCORRETA"
			
		# Aguardar 1 segundo
		await get_tree().create_timer(1.0).timeout
		
		# Resetar o título
		if titulo_label:
			titulo_label.text = "COMBINAÇÃO DO CADEADO"
		
		# Limpar os campos do cadeado
		if cadeado_ui.has_method("_on_clear_button_pressed"):
			cadeado_ui._on_clear_button_pressed()
