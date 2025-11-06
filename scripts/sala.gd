extends Node2D

const CODIGO_CORRETO = "3815"

@onready var dialogo_ui = $DialogoUI/MeuPainel
@onready var jogador = $Watson

func _ready():
	var jogador = get_tree().get_first_node_in_group("Player")
	
	if jogador and not Global.ponto_de_spawn_alvo.is_empty():
		var ponto_de_spawn = find_child(Global.ponto_de_spawn_alvo)
		
		if ponto_de_spawn:
			jogador.global_position = ponto_de_spawn.global_position
		else:
			print("AVISO: Ponto de spawn '", Global.ponto_de_spawn_alvo, "' não encontrado na Sala!")
			
		Global.ponto_de_spawn_alvo = ""
	
	# Conectar sinais
	dialogo_ui.dialogo_encerrado.connect(_on_dialogo_encerrado)
	
	# Conectar todas as evidências
	$EvidenciaCorpo.evidencia_escaneada.connect(_on_evidencia_escaneada)
	$EvidenciaPortaRetrato.evidencia_escaneada.connect(_on_evidencia_escaneada)

func _on_porta_para_quarto_body_entered(body):
	if body.is_in_group("Player"):
		Global.ponto_de_spawn_alvo = "PontoDeEntradaQuarto"
		FadeTransition.change_scene("res://cenas/Quarto.tscn")

func _on_porta_para_rua_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://cenas/Rua.tscn")

var dialogos = {
	"nota_fiscal": {
		"analise_holmes": "Análise: Uma transação para um componente eletrônico obsoleto, no valor de **$25**. O comprador é a vítima. A compra de tecnologia antiga é um padrão emergente neste caso.",
		"opcoes": [
			{"texto": "Anotado. Um valor... peculiar.", "resposta_holmes": "Concordo. A precisão do valor sugere importância."},
			{"texto": "O que era o componente?", "resposta_holmes": "Um capacitor de fluxo temporal de baixa potência. Inútil para qualquer tecnologia moderna. A não ser..."}
		]
	},
	"cadeado_quarto": {
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


func pode_interagir(id_da_pista: String) -> bool:
	return true

func iniciar_dialogo(id_da_pista: String):
	var dialogo_data = dialogos.get(id_da_pista) 
	
	if dialogo_data != null:
		jogador.travar_movimento(true)
		dialogo_ui.start_dialogue(dialogo_data)

# Função chamada quando o diálogo termina
func _on_dialogo_encerrado():
	jogador.travar_movimento(false)

# Função chamada quando qualquer evidência é escaneada
func _on_evidencia_escaneada(id_da_pista):
	if pode_interagir(id_da_pista):
		iniciar_dialogo(id_da_pista)
		
		# 1. Pega os dados do diálogo
		var dialogo_data = dialogos.get(id_da_pista)
		if dialogo_data:
			# 2. Pega as informações para o quadro
			var nome_pista = id_da_pista.replace("_", " ").capitalize()
		# Não precisamos mais da variável 'analise' aqui
			var sprite_pista = load("res://assets/icones_evidencias/" + id_da_pista + ".png")
			
			QuadroEvidencias.adicionar_evidencia(id_da_pista, nome_pista, sprite_pista, dialogo_data)
