# QuadroConexoes.gd
extends Control
signal evidencia_largada(data, posicao_local)

var evidencia_selecionada: PanelContainer = null
var conexoes: Array = [] 

# 1. O Godot pergunta: "Posso soltar isso aqui?"
func _can_drop_data(_at_position, data):
	return data is Dictionary and data.get("type") == "evidencia_inventario"

# 2. O Godot diz: "Ok, soltaram. Faça alguma coisa."
func _drop_data(at_position, data):
	print("Evidência ", data["nome"], " largada em ", at_position)
	# Avisa ao script principal (QuadroEvidencias) que algo foi largado
	emit_signal("evidencia_largada", data, at_position)

func _draw():
	for conexao in conexoes:
		# Pega a posição central de cada evidência
		var ponto_a = conexao[0].position + conexao[0].size / 2
		var ponto_b = conexao[1].position + conexao[1].size / 2
		# Desenha a "linha vermelha" de detetive
		draw_line(ponto_a, ponto_b, Color.CRIMSON, 2.0)
		
# Adicione esta função ao QuadroConexoes.gd
func _on_evidencia_no_quadro_clicada(evidencia: PanelContainer):
	
	if evidencia_selecionada == null:
		# 1. NADA SELECIONADO: Inicia uma nova cadeia.
		evidencia_selecionada = evidencia
		evidencia_selecionada.selecionar()
		
	elif evidencia_selecionada == evidencia:
		# 2. CLICOU NO MESMO ITEM: Cancela a cadeia.
		evidencia_selecionada.deselecionar()
		evidencia_selecionada = null
		
	else:
		# 3. CLICOU EM UM NOVO ITEM (A != B):
		# Vamos checar se uma conexão já existe entre eles, em qualquer direção.
		
		var conexao_encontrada = null
		for conexao in conexoes:
			if (conexao[0] == evidencia_selecionada and conexao[1] == evidencia) or \
			   (conexao[0] == evidencia and conexao[1] == evidencia_selecionada):
				conexao_encontrada = conexao
				break # Achamos!
		
		if conexao_encontrada:
			# 3a. CONEXÃO JÁ EXISTE: Remove-a.
			print("Removendo conexão entre ", evidencia_selecionada.name, " e ", evidencia.name)
			conexoes.erase(conexao_encontrada)
			
			# Limpa a seleção
			evidencia_selecionada.deselecionar()
			evidencia_selecionada = null
		else:
			# 3b. CONEXÃO NÃO EXISTE: Cria-a.
			print("Conectando ", evidencia_selecionada.name, " -> ", evidencia.name)
			conexoes.append([evidencia_selecionada, evidencia])
			
			# Desseleciona o item anterior e seleciona o novo
			evidencia_selecionada.deselecionar()
			evidencia_selecionada = evidencia
			evidencia_selecionada.selecionar()
		
		# Força o redesenho (para a linha aparecer ou sumir)
		queue_redraw()

func _remover_conexoes_da_evidencia(evidencia_a_remover):
	var novas_conexoes = []
	for conexao in conexoes:
		# Mantém apenas as conexões que NÃO contêm a evidência
		if conexao[0] != evidencia_a_remover and conexao[1] != evidencia_a_remover:
			novas_conexoes.append(conexao)
	conexoes = novas_conexoes # Substitui a lista antiga pela nova
	queue_redraw() # Força o redesenho (para apagar as linhas)

func _on_evidencia_arrastada():
	# Esta função força o quadro a redesenhar as linhas de conexão
	queue_redraw()

func _input(event):
	# Verifica se uma tecla foi pressionada, se o painel está visível
	# e se temos uma evidência selecionada (dourada)
	if event.is_action_pressed("ui_remove") and visible and evidencia_selecionada != null:
		
		# Verifica se a tecla SHIFT está pressionada
		if event.is_shift_pressed():
			# AÇÃO 1: REMOVER O ITEM INTEIRO (Shift + Delete)
			
			print("Removendo ITEM: ", evidencia_selecionada.name)
			_remover_conexoes_da_evidencia(evidencia_selecionada) # Remove as linhas
			evidencia_selecionada.queue_free() # Deleta o item
			evidencia_selecionada = null
			
		else:
			# AÇÃO 2: REMOVER APENAS AS CONEXÕES (Apenas Delete)
			
			print("Removendo CONEXÕES de: ", evidencia_selecionada.name)
			_remover_conexoes_da_evidencia(evidencia_selecionada)
			
			# Opcional: deselecionar o item após limpar suas linhas
			evidencia_selecionada.deselecionar()
			evidencia_selecionada = null
		
		# Confirma que o 'input' foi tratado
		get_viewport().set_input_as_handled()
