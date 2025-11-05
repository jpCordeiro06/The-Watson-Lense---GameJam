# dialogo_ui.gd 
extends PanelContainer

signal dialogo_encerrado

@onready var label_texto: RichTextLabel = $VBoxContainer/HBoxContainer/DialogoTexto
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer
@onready var timer_fechar_dialogo: Timer = $Timer 

func _ready():
	hide() # Começa escondido

# Função para iniciar a conversa: mostra a análise e cria os botões
func start_dialogue(data: Dictionary):
	# Limpa qualquer botão de conversas anteriores
	for child in choices_container.get_children():
		child.queue_free()
		
	# Mostra a análise inicial do HOLMES
	label_texto.text = data["analise_holmes"]
	
	# Cria os botões de opção
	for i in range(data["opcoes"].size()):
		var opcao_data = data["opcoes"][i]
		var new_button = Button.new()
		new_button.text = opcao_data["texto"]
		
		# Conecta o sinal 'pressed' do botão a nossa função de escolha
		new_button.pressed.connect(_on_opcao_escolhida.bind(opcao_data["resposta_holmes"]))
		
		choices_container.add_child(new_button)
	
	show()

# Função chamada quando o jogador clica em um botão de opção
func _on_opcao_escolhida(resposta_holmes: String):
	mostrar_dialogo(resposta_holmes)

# Mostra a resposta final de HOLMES.
func mostrar_dialogo(texto_resposta: String):
	# Remove os botões de opção da tela
	for child in choices_container.get_children():
		child.queue_free()
	
	# Mostra o texto da resposta final
	label_texto.text = texto_resposta
	
	# Inicia o timer para fechar a janela automaticamente
	timer_fechar_dialogo.start(4) # Fecha após 4 segundos

# Função chamada quando o timer termina
func _on_timer_fechar_dialogo_timeout():
	hide()
	emit_signal("dialogo_encerrado")
