
; Projeto Intermédio ACom 2021/2022 4º P 2º semestre

; André Melão ist1103517
; Fábio Sobrinho ist1103473
; João Pimentel ist19895
; GRUPO 04
;***********************************************************************************************************************
; Constantes
;***********************************************************************************************************************

DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA      EQU 00010H  ; linha a testar (começa na 4ª linha, 1000b)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
INICIAL    EQU 00064H  ; valor máximo de energia

MOVE_LEFT       EQU 00H     ; tecla para mover o rover para a esquerda (0)
DISPARO         EQU 01H	    ; tecla para disparar (1)
MOVE_RIGHT      EQU 02H     ; tecla para mover o rover para a direita (2)
GAME_OVER       EQU 03H     ; tecla para terminar o jogo (3)
PAUSE           EQU 05H     ; tecla para parar o jogo (5)
COMECAR_JOGO    EQU 06H     ; tecla para começar o jogo (6)
RESUME          EQU 06H     ; tecla para resumir o jogo (6)  
OUTRO_JOGO      EQU 06H     ; tecla para começar outro jogo (6)
VOLTAR_INICIO   EQU 07H     ; tecla para voltar ao principal (7)

DEFINE_LINHA    	    EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   	    EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    	    EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     	    EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 	        EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
SELECIONAR_SOM		    EQU 605CH
MOSTRAR_ECRÃ            EQU 6006H
ESCONDER_ECRÃ           EQU 6008H

LARGURA_1	EQU 1               ; tamanho do disparo e do meteoro de menor tamanho 
ALTURA_1	EQU 1

LARGURA_2	EQU 2               ; tamanho do meteoro 2x2
ALTURA_2	EQU 2

LARGURA_3	EQU 3               ; tamanho dos meteoros 3x3
ALTURA_3	EQU 3

LARGURA_4	EQU 4               ; tamanho dos meteoros 4x4
ALTURA_4	EQU 4

LARGURA_MAXIMO   EQU  5         ; tamanho dos meteoros 5x5 (máximo)	  
ALTURA_METEORO   EQU  5           


LINHA_ROVER     EQU  25            ; linha do boneco (a meio do ecrã)
ALTURA_ROVER    EQU  6             ; altura do rover  
MIN_COLUNA		EQU  0		       ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63            ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU 64H            ; atraso para limitar a velocidade de movimento do boneco

COR_VERDE		EQU 0F0F0H        ; cores usadas no jogo   
COR_LARANJA		EQU 0FF70H		     
COR_VERMELHO	EQU 0FF01H
COR_CINZENTO	EQU 0C877H
COR_AMARELO		EQU 0FFD0H
COR_AZUL		EQU 0F0FFH

N_LINHAS		EQU  32		; número de linhas do écrã
LIMITEMISSIL    EQU  9      ; linha onde o missil vai desaparecer

SECCAO0         EQU 0       ; secções onde os meteoros vão ser desenhados
SECCAO1         EQU 8
SECCAO2         EQU 16
SECCAO3         EQU 24
SECCAO4         EQU 32
SECCAO5         EQU 40
SECCAO6         EQU 48
SECCAO7         EQU 56
;***********************************************************************************************************************
; Definição de variáveis
;***********************************************************************************************************************

PLACE 1000H
pilha:	TABLE 100H
SP_inicial: 

; Tabela das rotinas de interrupção
tab:
    WORD rot_int_0      ; rotina de atendimento da interrupção 0
    WORD rot_int_1      ; rotina de atendimento da interrupção 1
    WORD rot_int_2      ; rotina de atendimento da interrupção 2

localizacao_meteoro:    ; irá guardar as posicoes em que o meteoro vai estar
    WORD 0
    WORD 0
localizacao_missil:     ; irá guardar as posicoes em que o missil vai estar
    WORD 24 
    WORD 0
energia:                ; valor inicial de energia
    WORD 100            
existe_missil:          ; valor que vai guardar quantos misseis existem no jogo
    WORD 0              
meteoro_a_desenhar:     ; irá guardar qual o meteoro que ira ser desenhado a seguir
    WORD 0              
posicao_aleatoria:      ; irá guardar a proxima coluna de onde o meteoro vai aparecer
    WORD 0              
coluna_rover:           ; irá guardar o valor da coluna do rover
    WORD 30
game_over_colisoes:     ; irá indicar se o game over devido a colisão é ativado 
    WORD 0
game_over_energia:      ; irá indicar se o game over devido à falta de energia é ativado
    WORD 0
rover:
DEF_BONECO_ROVER:		    ; tabela que define o rover (cor, largura, pixels)
	WORD	       LARGURA_MAXIMO, ALTURA_ROVER
	WORD	       0 , 0, COR_VERMELHO, 0, 0
	WORD	       0 , 0, COR_CINZENTO, 0, 0
	WORD           0, COR_AMARELO, COR_CINZENTO, COR_AMARELO, 0			
	WORD           0, COR_CINZENTO, COR_CINZENTO, COR_CINZENTO, 0
	WORD           COR_CINZENTO, 0, COR_CINZENTO, 0, COR_CINZENTO
	WORD           COR_LARANJA, 0, 0, 0, COR_LARANJA

meteoros_iniciais:          ; meteoros iniciais 
DEF_1POR1:
    WORD          LARGURA_1, ALTURA_1
    WORD          COR_CINZENTO  

DEF_2POR2:
    WORD          LARGURA_2, ALTURA_2
    WORD          COR_CINZENTO, COR_CINZENTO
    WORD          COR_CINZENTO, COR_CINZENTO 

meteoro_bom:                ; tabela que define os meteoros bons (cor, largura, pixels)
DEF_METEORO_BOM_3POR3:
    WORD        LARGURA_3, ALTURA_3
    WORD        COR_VERDE, 0, COR_VERDE
    WORD        COR_VERDE, COR_VERDE, COR_VERDE
    WORD        0, COR_VERDE, 0

DEF_METEORO_BOM_4POR4:
    WORD        LARGURA_4, ALTURA_4
    WORD        COR_VERDE, 0, 0, COR_VERDE
    WORD        COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE
    WORD        COR_VERDE, 0, 0, COR_VERDE
    WORD        0, COR_VERDE, COR_VERDE, 0

DEF_METEORO_BOM_MAXIMO:		
	WORD		LARGURA_MAXIMO, ALTURA_METEORO
	WORD		0, COR_VERDE, 0, COR_VERDE, 0		
	WORD        COR_VERDE, 0, COR_VERDE, 0, COR_VERDE
	WORD        COR_VERDE, 0, 0, 0, COR_VERDE
	WORD        0, COR_VERDE, 0, COR_VERDE, 0
	WORD		0, 0, COR_VERDE, 0, 0	
	 
meteoro_mau:                ; tabela que define os meteoros maus (cor, largura, pixels)
DEF_METEORO_MAU_3POR3:
    WORD        LARGURA_3, ALTURA_3
    WORD        COR_VERMELHO, 0, COR_VERMELHO
    WORD        0, COR_VERMELHO, 0
    WORD        COR_VERMELHO, 0, COR_VERMELHO

DEF_METEORO_MAU_4POR4:
    WORD        LARGURA_4, ALTURA_4
    WORD        COR_VERMELHO, 0, 0, COR_VERMELHO
    WORD        0, COR_VERMELHO, COR_VERMELHO, 0
    WORD        0, COR_VERMELHO, COR_VERMELHO, 0
    WORD        COR_VERMELHO, 0, 0, COR_VERMELHO

DEF_METEORO_MAU_MAXIMO:
	WORD		LARGURA_MAXIMO, ALTURA_METEORO
	WORD		COR_VERMELHO, 0, 0, 0, COR_VERMELHO
	WORD		0, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, 0
	WORD		COR_VERMELHO, COR_VERMELHO, 0, COR_VERMELHO, COR_VERMELHO
	WORD		0, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, 0
	WORD		COR_VERMELHO, 0, 0, 0, COR_VERMELHO
	
disparo:
DEF_DISPARO:            ; tabela que define o disparo (cor, largura, pixels)
	WORD		LARGURA_1, ALTURA_1
	WORD		COR_AZUL
;***********************************************************************************************************************
; Início
;***********************************************************************************************************************

    PLACE   0				                ; o código tem de começar em 0000H
inicio:
    MOV  BTE, tab
    MOV  SP, SP_inicial
    MOV  [APAGA_AVISO], R1	                ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	                ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV  R1, 0			                    ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1      ; seleciona o cenário de fundo
    MOV  [MOSTRAR_ECRÃ], R1
    MOV  R1, 0                              ; música de fundo nº 0
    MOV  [SELECIONAR_SOM], R1               ; seleciona a música de fundo em loop

iniciar_jogo:
    CALL teclado
    CMP R7, COMECAR_JOGO                    ; verifica se tecla 6 está premida (começar jogo)
    JNZ iniciar_jogo

preparar_jogo:
    MOV R1, 1
    MOV [SELECIONA_CENARIO_FUNDO], R1       ; seleciona o cenário de fundo
    MOV  R4, DISPLAYS			     
    MOV  R10, [energia]                     ; inicializa o display com o valor maximo de energia       
    CALL converte                   
    MOV  R9, 1                              ; a ser utilizado para posteriormente mudar o valor da coluna
    MOV  R4, 0                              ; usado para guardar os misseis existentes

desenhar_rover:                             ; desenha o rover(nave)
    MOV R1, LINHA_ROVER                     ; seleciona a linha do rover
    MOV R2, [coluna_rover]                  ; seleciona a coluna do rover     
    MOV R3, DEF_BONECO_ROVER                
    CALL desenha_boneco 
    EI0                                     ; permite interrupções 0
    EI1                                     ; permite interrupções 1                
    EI2                                     ; permite interrupções 2
    EI                     	                ; permite interrupções gerais
                     
rotina_teclado:                             ; função que chama teclado
    CALL teclado
    CMP R7, MOVE_LEFT			            ; tecla 0: mover o boneco para a esquerda 
    JZ move_esquerda
    CMP R7, MOVE_RIGHT                      ; tecla 2: mover o boneco para a direita 
    JZ move_direita
    CMP R7, DISPARO                         ; tecla 1: disparar o missil
    JZ desenha_disparo
    CMP R7, PAUSE                           ; tecla 5: pausar o jogo
    JZ pausa_jogo
    CMP R7, GAME_OVER                       ; tecla 3: terminar voluntariamente o jogo
    JZ termina_jogo
    MOV R8, [game_over_colisoes]            ; verifica se é para dar game over
    CMP R8, 1                               ; (a partir daqui)
    JZ termina_jogo
    MOV R8, [game_over_energia]             ; verifica se é para dar game over
    CMP R8, 1                               ; (a partir daqui)
    JZ termina_jogo
    JMP rotina_teclado
    
inicio_1:
    JMP inicio                             

termina_jogo:
    DI                                      ; para todas as interrupções
    MOV R8, [game_over_colisoes]         
    CMP R8, 1                               ; verifica se ecrã de game over colisões deve aparecer
    JZ ecra_game_over_colisoes 
    MOV R8, [game_over_energia]
    CMP R8, 1                               ; verifica se ecrã de game over energia deve aparecer
    JZ ecra_game_over_energia
    JMP ecra_game_over                      ; se não for nenhum deles significa que ocorreu um terminar de jogo voluntário

ecra_game_over:
    MOV [APAGA_ECRÃ], R1                    ; apaga o ecrã
    MOV R1, 3                               ; cenário de fundo nº4
    MOV [SELECIONA_CENARIO_FUNDO], R1       ; seleciona cenário de fundo nº4
    CALL apaga_missil_game_over             ; apaga missil (se existir)
    CALL valores_originais                  ; atualiza os valores guardados na memória
    CALL restaurar_registos                 ; atualiza os valores dos registos
    CALL teclado                             
    CMP R7, OUTRO_JOGO                      ; verifica se tecla 6 está premida
    JZ outro_jogo                           ; caso isso se verifique, reinicia o jogo
    CMP R7, VOLTAR_INICIO                   ; verifica se tecla 7 está premida
    JZ inicio                               ; caso isso se verifique, volta ao menu inicial
    JMP ecra_game_over                      ; se não for nenhum deles significa que fica à espera duma tecla


ecra_game_over_colisoes:
    MOV R8, 0          
    MOV [game_over_colisoes], R8            ; repõe o estado inicial da variável
    MOV R1, 4                               ; cenário de fundo nº5
    MOV [SELECIONA_CENARIO_FUNDO], R1       ; seleciona cenário de fundo nº4
    CALL apaga_missil_game_over             ; apaga missil (se existir)
    CALL valores_originais                  ; atualiza os valores guardados na memória
    CALL restaurar_registos                 ; atualiza os valores dos registos
    CALL teclado
    CMP R7, OUTRO_JOGO                      ; verifica se tecla 6 está premida
    JZ outro_jogo                           ; caso isso se verifique, reinicia o jogo
    CMP R7, VOLTAR_INICIO                   ; verifica se tecla 7 está premida
    JZ inicio                               ; caso isso se verifique, volta ao menu inicial
    JMP ecra_game_over_colisoes             ; se não for nenhum deles volta a repetir o processo

ecra_game_over_energia:
    MOV R8, 0
    MOV [game_over_energia], R8             ; repõe o estado inicial da variável
    MOV R1, 5                               ; cenário de fundo nº6
    MOV [SELECIONA_CENARIO_FUNDO], R1       ; seleciona cenário de fundo nº6
    CALL apaga_missil_game_over             ; apaga missil (se existir)
    CALL valores_originais                  ; atualiza os valores guardados na memória
    CALL restaurar_registos                 ; atualiza os valores dos registos
    CALL teclado
    CMP R7, OUTRO_JOGO                      ; verifica se tecla 6 está premida
    JZ outro_jogo                           ; caso isso se verifique, reinicia o jogo
    CMP R7, VOLTAR_INICIO                   ; verifica se tecla 7 está premida
    JZ inicio                               ; caso isso se verifique, volta ao menu inicial
    JMP ecra_game_over_energia              ; se não for nenhum deles volta a repetir o processo
    
pausa_jogo:
    MOV R1, 0                              
    MOV [ESCONDER_ECRÃ], R1                 ; esconde o ecrã
    MOV R1, 2                               ; cenário de fundo nº3
    MOV [SELECIONA_CENARIO_FUNDO], R1       ; seleciona cenário de fundo nº3
    DI                                      ; para todas as interrupções

espera_tecla_pausa:                     	              
    CALL teclado
    CMP R7, VOLTAR_INICIO                   ; verifica se tecla 7 está premida 
    JZ inicio_2                             ; caso isso se verifique, volta ao menu inicial
    CMP R7, RESUME                          ; verifica se tecla 6 está premida
    JZ volta_jogo                           ; caso isso se verifique, volta ao jogo
    JMP espera_tecla_pausa                  ; se não for nenhum deles volta a repetir o processo

inicio_2:
    CALL valores_originais                  ; atualiza os valores guardados na memória
    CALL restaurar_registos                 ; atualiza os valores dos registos
    JMP inicio_1                            ; volta ao menu inicial

volta_jogo:
    MOV R1, 0                              
    MOV [MOSTRAR_ECRÃ], R1                  ; mostra ecrã
    MOV R1, 1                               ; cenário de fundo nº2
    MOV [SELECIONA_CENARIO_FUNDO], R1       ; seleciona cenário de fundo nº2
    EI0                                     ; permite interrupções 0
    EI1                                     ; permite interrupções 1                
    EI2                                     ; permite interrupções 2
    EI                     	                ; permite todas as interrupções

outro_jogo:                                 
    JMP preparar_jogo                       ; reinicia tudo o que é necessário para começar um novo jogo

move_esquerda:
    MOV	R9, -1			                    ; vai deslocar para a esquerda
    JMP	ve_limites

move_direita:
    MOV	R9, +1			                    ; vai deslocar para a esquerda
    JMP	ve_limites

desenha_disparo:                            ; desenha o disparo 
    MOV R4, [existe_missil]                 
    ADD R4, 1                               ; adiciona um missil 
    CMP R4, 1                               ; já existe um missil no jogo?
    JGT volta_tecla                         ; se sim, sai da função e volta a esperar por tecla
    MOV [existe_missil], R4
    ADD	R2, 2                               ; utilizar coordenadas do rover para perceber onde disparar
    MOV [localizacao_missil+2], R2          ; guardar valor da coluna na memoria já que o missil move-se verticalmente
    SUB	R1, 1   
    MOV	R3, DEF_DISPARO
    CALL desenha_boneco                     ; desenha o disparo
    MOV R10, [energia]
    SUB R10, 5                              ; cada disparo: -5 de energia
    CALL converte
    MOV [energia], R10
    ADD	R1, 1                               ; voltamos a deixar as coordenadas do rover para outros usos
    SUB	R2, 2
    JMP	volta_tecla

volta_tecla:
    JMP rotina_teclado 
      
ve_limites:
    MOV	R3, DEF_BONECO_ROVER
    MOV	R6, [R3]			            ; obtém a largura do boneco
    CALL testa_limites		            ; vê se chegou aos limites do ecrã e se sim força R9 a 0
    CMP	R9,0                            ; vê se já chegou ao limite
    JZ 	volta_tecla
	
move_boneco:                            ; função que apaga o rover
	CALL apaga_boneco

coluna_seguinte:
	ADD	R2, R9			                ; para desenhar objeto na coluna seguinte (direita ou esquerda)
    MOV [coluna_rover], R2
	JMP	desenhar_rover		            ; vai desenhar o rover de novo

; **********************************************************************
; TECLADO - Função que controla o teclado
; Argumentos:   R2 - linha
;               R3 - coluna
;               R4 - displays
;
; Retorna: comportamento da tecla descrito no enunciado e um valor entre 0 e F correspondente ao valor da tecla premida
; **********************************************************************	

teclado:                                  
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11
    MOV  R2, TEC_LIN                    ; endereço do periférico das linhas
    MOV  R3, TEC_COL                    ; endereço do periférico das colunas
    MOV  R4, DISPLAYS                   ; endereço do periférico dos displays
    MOV  R5, MASCARA                    ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R11, INICIAL                   ; copiar valor inicial de energia para usá-lo em comparações

; corpo principal do programa
ciclo:
    MOV R1, LINHA                       ; começa o ciclo com valor 8 (4ª linha)

espera_tecla:                           ; neste ciclo espera-se até uma tecla ser premida
    MOV R8, [game_over_colisoes]        
    CMP R8, 1                           ; verifica se ecrã de game over colisões está ativo
    JZ pop_registos_over                ; se não for o caso, dá pop dos registos associados
    MOV R8, [game_over_energia]         
    CMP R8, 1                           ; verifica se ecrã de game over energia está ativo
    JZ pop_registos_over                ; se não for o caso, dá pop dos registos associados
    SHR R1, 1                           ; muda de linha de forma decrescente
    CMP R1, 0                           ; verifica se chegou a um valor em que não existe linha
    JZ  ciclo                           ; se verdade, o ciclo ira reiniciar para a linha de valor 8 
    MOVB [R2], R1                       ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]                       ; ler do periférico de entrada (colunas)
    MOV [posicao_aleatoria], R0         ; guardar valor de R0 para fazer posição aleatoria do boneco
    AND  R0, R5                         ; elimina bits para além dos bits 0-3
    CMP  R0, 0                          ; há tecla premida?
    JZ   espera_tecla                   ; se nenhuma tecla premida, repete
                                        ; vai mostrar a linha e a coluna da tecla
    MOV R6, R1                          ; guarda o valor apresentado no display
    MOV R7, 0                           ; inicializa variáveis que irão guardar valores da linha e coluna
    MOV R8, 0          

val_linha:                              ; vai encontrar o valor da linha
    CMP R6, 1                           ; verifica se chegou à primeira linha do teclado
    JZ val_coluna                       ; se verdade, vai encontrar o valor da coluna
    SHR R6, 1                           ; conta-se uma linha
    ADD R7, 1                           ; acrecscenta a contagem dessa linha para um registo
    JMP val_linha                       ; vai continuar a contar o número de linhas

val_coluna:                             ; vai encontrar o valor da coluna
    CMP R0, 1                           ; verifica se chegou à primeira linha do teclado
    JZ calcular_valor                   ; se verdade, vai calcular o valor
    SHR R0, 1                           ; conta-se uma coluna
    ADD R8, 1                           ; acrecscenta a contagem dessa coluna para um registo
    JMP val_coluna                      ; vai continuar a contar o número de colunas
    
calcular_valor:                         ; calcula valor usando os valores encontrados
    MOV R9, 4		                    ; função para calcular valor- 4*linha + coluna
    MUL R7, R9                          ; 4*linha
    ADD R7, R8		                    ; resultado anterior + coluna
    JMP pop_registos                    ; vai dar pop aos registos se a tecla nao tiver funcionalidade
    CMP R7, PAUSE
    JZ pausar_jogo
    
pausar_jogo:
    MOV R1, 0
    MOV [ESCONDER_ECRÃ], R1             ; esconde o ecrã
    MOV R1, 2                           ; cenário de fundo nº3
    MOV [SELECIONA_CENARIO_FUNDO], R1   ; seleciona cenário de fundo nº3
    DI                                  ; para todas as interrupções 

ha_tecla:                               ; neste ciclo espera-se até INICIALNENHUMA tecla estar premida
    MOVB [R2], R1                       ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]                       ; ler do periférico de entrada (colunas)
    AND  R0, R5                         ; elimina bits para além dos bits 0-3
    CMP  R0, 0                          ; há tecla premida?
    JNZ  ha_tecla                       ; se ainda houver uma tecla premida, espera até não haver
    
pop_registos:
    POP R11
    POP R10
    POP R9
    POP R8
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET
    
pop_registos_over:                     ; pop dos registos associados ao game over
    MOV R7, 4                          ; restaura o valor que se encontrava antes em R7
    POP R11
    POP R10
    POP R9
    POP R8
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET
; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   inverte o sentido de movimento
; Argumentos:		
;			R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R9 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R9 - novo sentido de movimento (pode ser o mesmo)	
; **********************************************************************

testa_limites:
	PUSH    R3
	PUSH	R5
	PUSH	R2
testa_limite_esquerdo:		            ; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA                  ; guarda o valor mínimo que a coluna pode ter
	CMP	R2, R5                          ; verifica se está no limite esquerdo
	JGT	testa_limite_direito
	CMP	R9, 0			                ; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	    
testa_limite_direito:		            ; vê se o boneco chegou ao limite direito
	ADD	R6, R2			                ; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA                  ; guarda o valor máximo que a coluna pode ter
	CMP	R6, R5                          ; verifica se está no limite direito
	JLE	sai_testa_limites	 
	CMP	R9, 0			                ; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R9, 0			                ; impede o movimento, forçando R9 a 0
sai_testa_limites:
	POP	R2
	POP	R5
	POP	R3
	RET
	   
; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;		 R3 - largura/cor (WORD)
;               R4 - altura
;		
; **********************************************************************
desenha_boneco:                         ; desenha o boneco a partir da tabela
    PUSH R5
	PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    MOV	R9, R1			                ; faz cópia da linha 
	MOV R7, R2			                ; faz copia da coluna
	MOV	R5, [R3]                        ; obtém a largura do boneco
    MOV R10, R5                         ; guarda este, ja que objetos tem larguras diferentes
	ADD	R3, 2                           ; endereço da altura
	MOV	R6, [R3]	                    ; obtém a altura do boneco
	ADD	R3, 2			                ; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:                         ; desenha os pixels do boneco a partir da tabela
	MOV  R8, [R3]	                    ; obtém a cor do próximo pixel do boneco
	MOV  [DEFINE_LINHA], R9             ; seleciona a linha
	MOV  [DEFINE_COLUNA], R7            ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R8	            ; altera a cor do pixel na linha e coluna selecionadas
	ADD  R3, 2			                ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R7, 1                          ; próxima coluna
	SUB  R5, 1	       	                ; menos uma coluna para tratar
	JNZ  desenha_pixels                 ; continua até percorrer toda a largura do objeto
	ADD  R9, 1	       	                ; próxima linha
	SUB  R6, 1 	       	                ; menos uma linha para tratar
	MOV  R7, R2	       	                ; reinicia a coluna
	MOV  R5, R10	                    ; recomeça a desenhar na largura
	CMP  R6, 0                          ; vê se a figura ja está desenhada
	JNZ  desenha_pixels                 ; se não for esse o caso, vai desenhar a próxima linha
	CALL atraso			                ; chama a funcao atraso de modo a ser percetivel o movimento da nave
    POP R10
	POP R9 
	POP R8
	POP R7
	POP R6
	POP R5
	RET    

; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - largura
;		 R4 - altura
;
; **********************************************************************

apaga_boneco:       			        ; desenha o boneco a partir da tabela
	PUSH	R5
	PUSH 	R6
	PUSH	R7
	PUSH	R8
	PUSH	R9
    PUSH    R10
	MOV	R9, R1			                ; cópia da linha do boneco
	MOV	R7, R2			                ; cópia da coluna do boneco
	MOV	R5, [R3]		                ; obtém a largura do boneco
    MOV R10, R5                         ; guarda este, ja que objetos tem larguras diferentes
	ADD	R3, 2                           ; endereço da altura
	MOV	R6, [R3]	                    ; obtém a altura do boneco

apaga_pixels:       			        ; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			                ; para apagar, a cor do pixel é sempre 0
	MOV  [DEFINE_LINHA], R9	            ; seleciona a linha
	MOV  [DEFINE_COLUNA], R7	        ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	            ; altera a cor do pixel na linha e coluna selecionadas
    ADD  R7, 1               	        ; próxima coluna
    SUB  R5, 1			                ; menos uma coluna para tratar
    JNZ  apaga_pixels			        ; continua até percorrer toda a largura do objeto
    ADD  R9, 1			                ; próxima linha
    SUB  R6, 1			                ; menos uma linha para tratar 
    MOV  R7, R2			                ; reinicia a coluna
    MOV  R5, R10			            ; recomeça a apagar na largura
    CMP  R6, 0			                ; vê se a figura está apagada
    JNZ  apaga_pixels 		            ; se não for esse o caso, vai apagar a próxima linha
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    RET
     
; **********************************************************************
; Atraso - Função que ira adicionar um atraso no programa
; 
; Argumentos:	
;		R11 - valor que irá ser decrementado
;
; **********************************************************************
atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1                          ; decremento do valor do atraso
	JNZ	ciclo_atraso
	POP	R11
	RET

; **********************************************************************
; RESTAURAR_REGISTOS - restaura registos para serem usados no proximo jogo
; **********************************************************************	
restaurar_registos:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11
    MOV R0, 0                   ; valor inicial dos registos (quando o programa começa)
    MOV R1, 0                   ; usado para não haver informação não pretendida no proximo jogo
    MOV R2, 0
    MOV R3, 0
    MOV R4, 0
    MOV R5, 0
    MOV R6, 0
    MOV R7, 0
    MOV R8, 0
    MOV R9, 0
    MOV R10, 0
    MOV R11, 0
    POP R11
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; **********************************************************************
; VALORES_ORIGINAIS - mete no valor original os valores guardados em memoria
; **********************************************************************	
valores_originais:                  
    PUSH R1
    PUSH R10
    MOV R10, 100                        ; valor inicial de energia
    MOV [energia], R10
    MOV R1, 0                           ; valor inicial das variaveis seguintes
    MOV [localizacao_meteoro], R1
    MOV [localizacao_meteoro+2], R1
    MOV [localizacao_missil+2], R1
    MOV [existe_missil], R1
    MOV [meteoro_a_desenhar], R1
    MOV [posicao_aleatoria], R1
    MOV R1, 24                          ; valor inicial da linha do missil
    MOV [localizacao_missil], R1
    MOV R1, 30                          ; valor inicial da coluna do rover
    MOV [coluna_rover], R1
    POP R10
    POP R1
    RET

; **********************************************************************
; APAGA_MISSIL_GAME_OVER - apaga o missil (se existir) quando há gameover
; **********************************************************************
apaga_missil_game_over:
    PUSH R1
    PUSH R2
    PUSH R3
    MOV R1, [existe_missil]
    CMP R1, 1                       ; existe missil?
    JNZ nao_existe_missil           ; se não, sai da rotina
    MOV R1, [localizacao_missil]    ; se sim, vai apagar o disparo
    MOV R2, [localizacao_missil+2]
    MOV R3, DEF_DISPARO
    CALL apaga_boneco

nao_existe_missil:
    POP R3
    POP R2
    POP R1
    RET

; **********************************************************************
; ROT_INT_0 - Rotina de atendimento da interrupção 0
;             Assinala o evento na componente 0 da variável tab_eventos_interr
; **********************************************************************
rot_int_0:
    CALL anima_meteoro
    RFE 

; **********************************************************************
; ROT_INT_1 - Rotina de atendimento da interrupção 1
;             Assinala o evento na componente 1 da variável tab_eventos_interr
; **********************************************************************
rot_int_1:
    CALL anima_missil
    RFE

; **********************************************************************
; ROT_INT_2 - Rotina de atendimento da interrupção 2
;             Assinala o evento na componente 2 da variável tab_eventos_interr
; **********************************************************************
rot_int_2:
    PUSH R10
    PUSH R4

    MOV  R4, DISPLAYS
    MOV  R10, [energia]                ; energia no momento
    SUB  R10, 5                        ; decrementa 5 a esse valor
    CALL converte
    MOV  [energia], R10                ; guarda o valor decrementado em memoria
    CMP  R10, 0                        ; verifica se energia está a 0
    JNZ pop_int                        ; caso não esteja a 0, dá pop dos registos e continua
    MOV [APAGA_ECRÃ], R4               ; caso esteja apaga o ecrã
    MOV R4, 1                          ; e guarda 1
    MOV [game_over_energia], R4        ; na variável do game over energia

pop_int:
    POP  R4                        
    POP  R10
    RFE 
; **********************************************************************
; ANIMA_METEORO - Desenha e faz descer o meteoro que está no ecrâ
;			 Se chegar ao fundo, passa ao topo.
;			 A linha em que o meteoro é escrito é guardada na variável tab
; Argumentos: Nenhum
; **********************************************************************
anima_meteoro:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
    PUSH R5
	MOV  R3, [meteoro_a_desenhar]	 
	MOV  R2, [localizacao_meteoro+2]	    ; coluna a partir da qual o meteoro é desenhado
	MOV  R1, [localizacao_meteoro]          ; linha em que o meteoro está
    CMP  R3, 0                              ; se n hover meteoro para ser desenhado, irá ser criado
    JZ inicializa_meteoro
	CALL apaga_boneco	                    ; apaga o boneco do ecrã
	ADD  R1, 1			                    ; passa à linha abaixo
	MOV  R4, N_LINHAS
	CMP  R1, R4			                    ; já estava na linha do fundo?
	JLT  escreve_boneco
	MOV  R1, 0			                    ; volta ao topo do ecrã
    JMP  inicializa_meteoro                 ; irá ser criado um meteoro numa nova posição

inicializa_meteoro:
    CALL meteoro_aleatorio

escreve_boneco:
    MOV [localizacao_meteoro], R1
    MOV R2, [localizacao_meteoro+2]         ; se a posição mudar, guardá-la na memória
    CALL aumentar_meteoro
    MOV R3, [meteoro_a_desenhar]            ; guarda em R3 o valor do meteoro a desenhar para
	CALL desenha_boneco		                ; desenhar o meteoro com essas dimensões
    MOV R3, [meteoro_a_desenhar]         
    MOV R5, [R3]                            ; guarda num registo o valor do meteoro para poder comparar
    CMP R5, 5                               ; verifica se dimensões do meteoro são 5x5
    JNZ acaba_meteoro
    CALL colisoes_rover_meteoro

acaba_meteoro:
    POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET

; **********************************************************************
; ANIMA_MISSIL - Desenha e faz descer o meteoro que está no ecrâ
;			 Se chegar ao fundo, passa ao topo.
;			 A linha em que o meteoro é escrito é guardada na variável tab
; Argumentos: Nenhum
; **********************************************************************
anima_missil:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
    PUSH R5
	MOV  R3, DEF_DISPARO	 
	MOV  R2, [localizacao_missil+2]	    ; coluna a partir da qual o missil é desenhado
	MOV  R1, [localizacao_missil]       ; linha em que o missil está
    MOV  R5, [existe_missil]            ; quantos misseis existem
    CMP  R5, 0                          ; não existe missil
    JZ   eliminar_missil                ; sai da rotina de interrpção a fazer nada
	CALL apaga_boneco	                ; apaga o missil do ecrã
	SUB  R1, 1			                ; passa à linha acima
	MOV  R4, LIMITEMISSIL
	CMP  R1, R4			                ; já está na linha limite?
	JGE  escreve_missil                 ; se sim, irá voltar aos valores originais para estes serem usados no proximo missil
    SUB  R5, 1                          
    MOV  [existe_missil], R5            ; define o valor da variável 
    MOV  R1, 24
    MOV  [localizacao_missil], R1       ; repõe o valor da linha do míssil
    MOV  R2, 0
    MOV  [localizacao_missil+2], R2     ; repõe o valor da coluna do míssil
	JMP  eliminar_missil          

escreve_missil:
    MOV [localizacao_missil], R1        ; redefine o valor da linha do míssil    
    MOV R3, DEF_DISPARO
	CALL desenha_boneco                 ; escreve o missil na nova linha      		            
    CALL colisoes_missil_meteoro

eliminar_missil:
    POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET

; **********************************************************************
; METEORO_ALEATORIO - Vai desobrir em que secção o proximo meteoro sera
; posto
;                       Argumentos- valor descoberto em teclado
;                       Devolve- linha, coluna e METEORO que ira ser feito
; **********************************************************************
meteoro_aleatorio:                      ; função para ver o meteoro
    PUSH R0
    PUSH R1
    PUSH R2
    MOV R0, [posicao_aleatoria]         ; guardar posicao aleatoria
    SHR R0, 5                           ; numero entre 0 e 7 (teremos 8 secções)  
    CMP R0, 0                           ; irá verificar se R0 equivale ao numero da secção
    JNZ proxima_seccao1                 ; se sim, vai-nos dar a nova coluna onde o meteoro vai ser desenhado
    MOV R1, SECCAO0                     ; guarda valor da secção 0
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
    JMP guarda_valores                  ; irá atualizar os valores da coluna e do meteoro a desenhar  
proxima_seccao1:
    CMP R0, 1                           ; irá verificar se R0 equivale ao numero da secção
    JNZ proxima_seccao2                 ; se sim, vai-nos dar a nova coluna onde o meteoro vai ser desenhado
    MOV R1, SECCAO1                     ; guarda valor da secção 1
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
    JMP guarda_valores                  ; irá atualizar os valores da coluna e do meteoro a desenhar
proxima_seccao2:
    CMP R0, 2                           ; irá verificar se R0 equivale ao numero da secção
    JNZ proxima_seccao3                 ; se sim, vai-nos dar a nova coluna onde o meteoro vai ser desenhado
    MOV R1, SECCAO2                     ; guarda valor da secção 2
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
    JMP guarda_valores                  ; irá atualizar os valores da coluna e do meteoro a desenhar
proxima_seccao3:
    CMP R0, 3                           ; irá verificar se R0 equivale ao numero da secção
    JNZ proxima_seccao4                 ; se sim, vai-nos dar a nova coluna onde o meteoro vai ser desenhado
    MOV R1, SECCAO3                     ; guarda valor da secção 3
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
    JMP guarda_valores                  ; irá atualizar os valores da coluna e do meteoro a desenhar
proxima_seccao4:
    CMP R0, 4                           ; irá verificar se R0 equivale ao numero da secção
    JNZ proxima_seccao5                 ; se sim, vai-nos dar a nova coluna onde o meteoro vai ser desenhado
    MOV R1, SECCAO4                     ; guarda valor da secção 4
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
    JMP guarda_valores                  ; irá atualizar os valores da coluna e do meteoro a desenhar
proxima_seccao5:
    CMP R0, 5                           ; irá verificar se R0 equivale ao numero da secção
    JNZ proxima_seccao6                 ; se sim, vai-nos dar a nova coluna onde o meteoro vai ser desenhado
    MOV R1, SECCAO5                     ; guarda valor da secção 5
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
    JMP guarda_valores                  ; irá atualizar os valores da coluna e do meteoro a desenhar
proxima_seccao6:
    CMP R0, 6                           ; irá verificar se R0 equivale ao numero da secção
    JNZ proxima_seccao7                 ; se sim, vai-nos dar a nova coluna onde o meteoro vai ser desenhado
    MOV R1, SECCAO6                     ; guarda valor da secção 6
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
    JMP guarda_valores                  ; irá atualizar os valores da coluna e do meteoro a desenhar
proxima_seccao7:                        ; entra nesta função se não entrar nas outras
    MOV R1, SECCAO7                     ; guarda o valor da secção 7
    MOV R2, DEF_1POR1                   ; guarda as características do meteoro 1x1
guarda_valores:
    MOV [localizacao_meteoro+2], R1     ; guarda os novos valores da coluna
    MOV [meteoro_a_desenhar], R2        ; guarda o valor do novo meteoro a desenhar                         
    POP R2                                   
    POP R1
    POP R0
    RET

; **********************************************************************
; AUMENTAR_METEORO - aumenta o meteoro dependendo da linha onde está
;                       Argumentos- valor da linha no momento
;                       Devolve- meteoro que irá ser desenhado
; **********************************************************************
aumentar_meteoro:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    MOV R0, [localizacao_meteoro]       ; guarda a linha do meteoro
    MOV R1, 3                           ; guarda o valor da linha onde vai fazer as transformações
    MOV R3, [localizacao_meteoro+2]     ; guarda a coluna do meteoro
    MOV R4, SECCAO1                     ; nestas secções iremos desenhar meteoros bons
    MOV R5, SECCAO6

    CMP R0, R1                          ; verifica se meteoro se econtra na linha correta para transformação (3)
    JNZ proxima_linha1                  
    MOV R2, DEF_2POR2                   ; caso esteja guarda as características do meteoro 2x2
    MOV [meteoro_a_desenhar], R2        ; guarda o meteoro a desenhar
    JMP sai_ciclo                       ; dá pop dos registos

proxima_linha1:
    ADD R1, 3                           ; adiciona 3 à linha das transformações
    CMP R0, R1                          ; verifica se linha do meteoro é igual à linha das transformações
    JNZ proxima_linha2                  ; se não for, vai ver se executa a nova transformação
    JMP descobrir_meteoro
    
descobrir_meteoro:                      ; se for para 3x3, temos que ver se o meteoro vai ser bom ou mau
    CMP R3, R4                          ; vai comparar a coluna de onde o meteoro está a ser desenhado com as secções
    JZ desenhar_meteoro_bom
    CMP R3, R5
    JZ desenhar_meteoro_bom             ; se forem iguais, desenha meteoros bons a partir daqui
    MOV R2, DEF_METEORO_MAU_3POR3       ; se não, desenha meteoros maus
    MOV [meteoro_a_desenhar], R2        ; guarda o meteoro a desenhar
    JMP sai_ciclo                       ; dá pop dos registos

desenhar_meteoro_bom:
    MOV R2, DEF_METEORO_BOM_3POR3       ; guarda as características do meteoro 3x3
    MOV [meteoro_a_desenhar], R2        ; guarda o meteoro a desenhar
    JMP sai_ciclo                       ; dá pop dos registos

proxima_linha2:
    ADD R1, 3                           ; adiciona 3 à linha das transformações
    CMP R3, R4                          ; compara coluna onde meteoro está a ser desenhado com as secções  
    JZ proxima_linha3_bom               ; se forem iguais, vai verificar isso nos meteoros bons
    CMP R3, R5                     
    JZ proxima_linha3_bom              
    JMP proxima_linha3_mau              ; se não, verifica-se nos meteoros maus

proxima_linha3_bom:
    CMP R0, R1                          ; verifica se meteoro se econtra na linha correta para transformação (12)
    JNZ proxima_linha4_bom              ; se não for a correta, vai para a próxima transformação
    MOV R2, DEF_METEORO_BOM_4POR4       ; caso seja guarda as características do meteoro 4x4
    MOV [meteoro_a_desenhar], R2        ; guarda o meteoro a desenhar
    JMP sai_ciclo                       ; dá pop dos registos

proxima_linha3_mau:
    CMP R0, R1                          ; verifica se meteoro se econtra na linha correta para transformação (12)
    JNZ proxima_linha4_mau              ; se não for a correta, vai para a próxima transformação
    MOV R2, DEF_METEORO_MAU_4POR4       ; caso seja guarda as características do meteoro 4x4
    MOV [meteoro_a_desenhar], R2        ; guarda o meteoro a desenhar
    JMP sai_ciclo                       ; dá pop dos registos

proxima_linha4_bom:
    ADD R1, 3                           ; adiciona 3 à linha das transformações
    CMP R0, R1                          ; verifica se meteoro se econtra na linha correta para transformação (15)
    JNZ sai_ciclo                   
    MOV R2, DEF_METEORO_BOM_MAXIMO      ; caso esteja guarda as características do meteoro 5x5
    MOV [meteoro_a_desenhar], R2        ; guarda o meteoro a desenhar
    JMP sai_ciclo                       ; dá pop dos registos

proxima_linha4_mau:
    ADD R1, 3                           ; adiciona 3 à linha das transformações
    CMP R0, R1                          ; verifica se meteoro se econtra na linha correta para transformação (15)
    JNZ sai_ciclo                       ; dá pop dos registos
    MOV R2, DEF_METEORO_MAU_MAXIMO      ; caso esteja guarda as características do meteoro 5x5
    MOV [meteoro_a_desenhar], R2        ; guarda o meteoro a desenhar

sai_ciclo:
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; **********************************************************************
; COLISOES_ROVER_METEORO - verifica se existe uma colisão entre o rover e um meteoro
;                       Argumentos- posicoes do meteoro e do rover 
;                       Devolve- o meteoro apagado se existir uma colisão
;                       se não existir, nada.
; **********************************************************************
colisoes_rover_meteoro:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11
    MOV R0, LINHA_ROVER
    MOV R1, [coluna_rover]
    MOV R2, [localizacao_meteoro]       ; linha do meteoro
    MOV R3, [localizacao_meteoro+2]     ; coluna do meteoro
    MOV R4, [meteoro_a_desenhar]        ; meteoro a ser desenhado
    MOV R5, SECCAO1                     ; secções dos meteoros bons
    MOV R6, SECCAO6
    MOV R7, 0                           ; flags para simbolizar quantas linhas e colunas foram vistas
    MOV R8, 0
    MOV R9, 0
    MOV R11, 0

verifica_meteoro_linha:
    ADD R7, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas do meteoro ja foram verificadas)
    CMP R0, R2                          ; compara a linha do meteoro com a do rover
    JZ  verifica_meteoro_coluna         ; se forem iguais vai verificar a coluna
    ADD R2, 1                           ; se não, vamos ver a próxima linha do meteoro
    CMP R7, 5                           ; verificou as linhas todas do meteoro?
    JNZ verifica_meteoro_linha          ; se não, vai verificar
    MOV R2, [localizacao_meteoro]       ; se sim, vamos mudar a linha do rover
    MOV R7, 0                           ; voltar a meter as linhas ja vistas do meteoro como original
    ADD R0, 1                           ; se não, vamos ver a próxima linha do rover
    ADD R8, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas do rover ja foram verificadas)
    CMP R8, 6                           ; verificou as linhas todas do rover?
    JNZ verifica_meteoro_linha          ; se não, vai verificar
    JMP sai_colisoes_rover              ; se sim, significa que não há colisão

verifica_meteoro_coluna:
    ADD R9, 1                           ; adiciona 1 a esta flag (vai verificar quantas colunas do meteoro ja foram verificadas)
    CMP R1, R3                          ; compara a coluna do meteoro com a do rover
    JZ colisao_rover                    ; se forem iguais, existe colisão
    ADD R3, 1                           ; se não, vamos ver a próxima coluna do meteoro
    CMP R9, 5                           ; verificou as colunas todas do meteoro?
    JNZ verifica_meteoro_coluna         ; se não, vai verificar
    MOV R3, [localizacao_meteoro+2]     ; se sim, vamos mudar a colunas do rover
    MOV R9, 0                           ; voltar a meter as colunas ja vistas do meteoro como original
    ADD R1, 1                           ; se não, vamos ver a próxima coluna do rover
    ADD R11, 1                          ; adiciona 1 a esta flag (vai verificar quantas colunas do rover ja foram verificadas)
    CMP R11, 5                          ; verificou as colunas todas do rover?
    JNZ verifica_meteoro_coluna         ; se não, vai verificar
    JMP sai_colisoes_rover              ; se sim, significa que não há colisão

colisao_rover:
    MOV R3, [localizacao_meteoro+2]     ; coluna do meteoro
    CMP R3, R5                          ; se for igual a das secções das colunas, existe colisao com um meteoro bom
    JZ colisao_rover_bom
    CMP R3, R6
    JZ colisao_rover_bom
    JMP colisao_rover_mau               ; se não, existe colisao com um meteoro mau

colisao_rover_bom:
    MOV R1, [localizacao_meteoro]       ; linha do meteoro
    MOV R2, [localizacao_meteoro+2]     ; coluna do meteoro
    MOV R3, [meteoro_a_desenhar]        ; meteoro já desenhado
    CALL apaga_boneco                   ; apaga o meteoro
    MOV R10, [energia]                  ; energia
    MOV R11, 10                         ; contacto com um meteoro bom: +10 de energia
    ADD R10, R11                        ; adiciona à energia
    CALL converte
    MOV [energia], R10                  ; guarda o valor mudado na memoria
    MOV  R1, 0
    MOV  [localizacao_meteoro], R1      ; mete a linha do meteoro como original
    CALL meteoro_aleatorio              ; vai desenhar um meteoro logo a seguir
    JMP sai_colisoes_rover

colisao_rover_mau:
    MOV [APAGA_ECRÃ], R1	                ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV R1, 1
    MOV [game_over_colisoes], R1            ; vai meter game_over_colisoes a 1 (ou seja, ecrã de game over vai ser posto)
    
sai_colisoes_rover:
    POP R11
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2 
    POP R1
    POP R0
    RET

; **********************************************************************
; COLISOES_MISSIL_METEORO - verifica se existe uma colisão entre um missil e um meteoro
;                       Argumentos- posicoes do meteoro e do missil 
;                       Devolve- o missil e o meteoro apagados se existir uma colisão
;                       se não existir, nada.
; **********************************************************************
colisoes_missil_meteoro:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11
    MOV R0, [localizacao_missil]
    MOV R1, [localizacao_missil+2]
    MOV R2, [localizacao_meteoro]
    MOV R3, [localizacao_meteoro+2]
    MOV R4, [meteoro_a_desenhar]
    MOV R5, SECCAO1                     ; nestas secções são para meteoros bons
    MOV R6, SECCAO6
    MOV R7, [existe_missil]
    MOV R8, 0                           ; flags para a verificação de colisão do meteoro
    MOV R9, 0
    MOV R11, 0

ver_meteoros:
    CMP R3, R5                          ; verifica em que secção o meteoro se encontra
    JZ verifica_meteoro_bom
    CMP R3, R6
    JZ verifica_meteoro_bom             ; se se encontrar numa secção boa, vai verificar os meteoros bons
    JMP verifica_meteoro_mau            ; se não, verifica meteoros maus

verifica_meteoro_bom:
    MOV R8, [R4]                        ; vai buscar a largura do meteoro a ser desenhado
    CMP R8, 3                           ; compara a largura do meteoro atual com 3
    JZ  colisoes_bom_3x3_linha          ; se sim, verifica as colisões em 3x3
    CMP R8, 4                           ; compara a largura do meteoro atual com 4
    JZ  colisoes_bom_4x4_linha          ; se sim, verifica as colisões em 4x4
    CMP R8, 5                           ; compara a largura do meteoro atual com 5
    JZ  colisoes_bom_5x5_linha          ; se sim, verifica as colisões em 5x5
    JMP sai_colisoes                    ; se ainda não chegou a um meteoro bom, sai deste ciclo 

colisoes_bom_3x3_linha:
    ADD R9, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas ja foram verificadas)
    CMP R2, R0                          ; compara a linha do meteoro com a do missil
    JZ colisoes_bom_3x3_coluna          ; se forem iguais vai verificar a coluna
    ADD R2, 1                           ; se não, vamos ver a próxima linha
    CMP R9, 3                           ; verificou as linhas todas?
    JNZ colisoes_bom_3x3_linha          ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não ha colisão

colisoes_bom_3x3_coluna:
    ADD R11, 1                          ; adiciona 1 a esta flag (vai verificar quantas colunas ja foram verificadas)
    CMP R3, R1                          ; compara a coluna do meteoro com a do missil
    JZ existe_colisao_bom               ; se forem iguais, existe colisão
    ADD R3, 1                           ; se não, vamos ver a próxima coluna
    CMP R11, 3                          ; verificou as colunas todas?
    JNZ colisoes_bom_3x3_coluna         ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não há colisão 

colisoes_bom_4x4_linha:
    ADD R9, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas ja foram verificadas)
    CMP R2, R0                          ; compara a linha do meteoro com a do missil       
    JZ colisoes_bom_4x4_coluna          ; se forem iguais vai verificar a coluna
    ADD R2, 1                           ; se não, vamos ver a próxima linha
    CMP R9, 4                           ; verificou as linhas todas?
    JNZ colisoes_bom_4x4_linha          ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não ha colisão

colisoes_bom_4x4_coluna:
    ADD R11, 1                          ; adiciona 1 a esta flag (vai verificar quantas colunas ja foram verificadas)
    CMP R3, R1                          ; compara a coluna do meteoro com a do missil
    JZ existe_colisao_bom               ; se forem iguais, existe colisão
    ADD R3, 1                           ; se não, vamos ver a próxima coluna
    CMP R11, 4                          ; verificou as colunas todas?
    JNZ colisoes_bom_4x4_coluna         ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não há colisão 

colisoes_bom_5x5_linha:
    ADD R9, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas ja foram verificadas)
    CMP R2, R0                          ; compara a linha do meteoro com a do missil
    JZ colisoes_bom_5x5_coluna          ; se forem iguais vai verificar a coluna
    ADD R2, 1                           ; se não, vamos ver a próxima linha
    CMP R9, 5                           ; verificou as linhas todas?
    JNZ colisoes_bom_5x5_linha          ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não ha colisão

colisoes_bom_5x5_coluna:
    ADD R11, 1                          ; adiciona 1 a esta flag (vai verificar quantas colunas ja foram verificadas)
    CMP R3, R1                          ; compara a coluna do meteoro com a do missil
    JZ  caso_especial_bom               ; se forem iguais, existe colisão
    ADD R3, 1                           ; se não, vamos ver a próxima coluna
    CMP R11, 5                          ; verificou as colunas todas?
    JNZ colisoes_bom_5x5_coluna         ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não há colisão 

caso_especial_bom:                      ; em certas situações, não queremos que ele faça colisão (devido à forma do meteoro)
    CMP R9, 5                           ; nesta situação queremos que as posições 5x1 e 5x5 do meteoro bom 5x5 não façam a colisão
    JNZ existe_colisao_bom
    CMP R11, 1
    JZ sai_colisoes
    CMP R11, 5
    JZ sai_colisoes

existe_colisao_bom:
    MOV R1, [localizacao_missil]        ; linha do missil
    MOV R2, [localizacao_missil+2]      ; coluna do missil
    MOV R3, DEF_DISPARO
    CALL apaga_boneco                   ; apaga o missil
    MOV R1, [localizacao_meteoro]       ; linha do meteoro
    MOV R2, [localizacao_meteoro+2]     ; coluna do meteoro
    MOV R3, [meteoro_a_desenhar]
    CALL apaga_boneco                   ; apaga o meteoro
    SUB  R7, 1
    MOV [existe_missil], R7             ; diz que não existe missil
    MOV  R1, 24
    MOV  [localizacao_missil], R1
    MOV  R2, 0                          
    MOV  [localizacao_missil+2], R2     ; mete os valores do missil como original
    MOV  R1, 0
    MOV  [localizacao_meteoro], R1      ; mete a linha do meteoro como original
    CALL meteoro_aleatorio              ; vai meter outro meteoro no ecrã
    JMP sai_colisoes

verifica_meteoro_mau:
    MOV R8, [R4]                        ; vai buscar a largura do meteoro a ser desenhado
    CMP R8, 3                           ; compara a largura do meteoro atual com 3
    JZ  colisoes_mau_3x3_linha          ; se sim, verifica as colisões em 3x3
    CMP R8, 4                           ; compara a largura do meteoro atual com 4
    JZ  colisoes_mau_4x4_linha          ; se sim, verifica as colisões em 4x4
    CMP R8, 5                           ; compara a largura do meteoro atual com 5
    JZ  colisoes_mau_5x5_linha          ; se sim, verifica as colisões em 5x5
    JMP sai_colisoes                    ; se ainda não chegou a um meteoro mau, sai deste ciclo

colisoes_mau_3x3_linha:
    ADD R9, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas ja foram verificadas)
    CMP R2, R0                          ; compara a linha do meteoro com a do missil
    JZ colisoes_mau_3x3_coluna          ; se forem iguais vai verificar a coluna
    ADD R2, 1                           ; se não, vamos ver a próxima linha
    CMP R9, 3                           ; verificou as linhas todas?
    JNZ colisoes_mau_3x3_linha          ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não ha colisão

colisoes_mau_3x3_coluna:
    ADD R11, 1                          ; adiciona 1 a esta flag (vai verificar quantas colunas ja foram verificadas)
    CMP R3, R1                          ; compara a coluna do meteoro com a do missil
    JZ existe_colisao_mau               ; se forem iguais, existe colisão
    ADD R3, 1                           ; se não, vamos ver a próxima coluna
    CMP R11, 3                          ; verificou as colunas todas?
    JNZ colisoes_mau_3x3_coluna         ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não há colisão 

colisoes_mau_4x4_linha:
    ADD R9, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas ja foram verificadas)
    CMP R2, R0                          ; compara a linha do meteoro com a do missil
    JZ colisoes_mau_4x4_coluna          ; se forem iguais vai verificar a coluna
    ADD R2, 1                           ; se não, vamos ver a próxima linha
    CMP R9, 4                           ; verificou as linhas todas?
    JNZ colisoes_mau_4x4_linha          ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não ha colisão

colisoes_mau_4x4_coluna:
    ADD R11, 1                          ; adiciona 1 a esta flag (vai verificar quantas colunas ja foram verificadas)
    CMP R3, R1                          ; compara a coluna do meteoro com a do missil
    JZ  caso_especial_mau               ; se forem iguais, existe colisão
    ADD R3, 1                           ; se não, vamos ver a próxima coluna
    CMP R11, 4                          ; verificou as colunas todas?
    JNZ colisoes_mau_4x4_coluna         ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não há colisão 

colisoes_mau_5x5_linha:     
    ADD R9, 1                           ; adiciona 1 a esta flag (vai verificar quantas linhas ja foram verificadas)
    CMP R2, R0                          ; compara a linha do meteoro com a do missil
    JZ colisoes_mau_5x5_coluna          ; se forem iguais vai verificar a coluna
    ADD R2, 1                           ; se não, vamos ver a próxima linha
    CMP R9, 5                           ; verificou as linhas todas?
    JNZ colisoes_mau_5x5_linha          ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não há colisão 

colisoes_mau_5x5_coluna:    
    ADD R11, 1                          ; adiciona 1 a esta flag (vai verificar quantas colunas ja foram verificadas)
    CMP R3, R1                          ; compara a coluna do meteoro com a do missil
    JZ existe_colisao_mau               ; se forem iguais, existe colisão
    ADD R3, 1                           ; se não, vamos ver a próxima coluna
    CMP R11, 5                          ; verificou as colunas todas?
    JNZ colisoes_mau_5x5_coluna         ; se não, vai verificar
    JMP sai_colisoes                    ; se sim, significa que não há colisão 

caso_especial_mau:                      ; em certas situações, não queremos que ele faça colisão (devido à forma do meteoro)
    CMP R9, 3                           ; nesta situação queremos que as posições 3x1 e 3x4 do meteoro mau 4x4 não façam a colisão
    JNZ existe_colisao_mau
    CMP R11, 1
    JZ sai_colisoes
    CMP R11, 4
    JZ sai_colisoes

existe_colisao_mau:
    MOV R1, [localizacao_missil]       ; linha do missil
    MOV R2, [localizacao_missil+2]     ; coluna do missil
    MOV R3, DEF_DISPARO
    CALL apaga_boneco                  ; apaga o missil
    MOV R1, [localizacao_meteoro]      ; linha do meteoro 
    MOV R2, [localizacao_meteoro+2]    ; coluna do meteoro
    MOV R3, [meteoro_a_desenhar]
    CALL apaga_boneco                  ; apaga o meteoro
    MOV R10, [energia]
    ADD R10, 5                         ; quando matas um meteoro mau: +5 de energia
    CALL converte
    MOV [energia], R10                 ; mete o valor mudado na memoria
    SUB  R7, 1
    MOV [existe_missil], R7            ; diz que não existe missil
    MOV  R1, 24
    MOV  [localizacao_missil], R1
    MOV  R2, 0
    MOV  [localizacao_missil+2], R2
    MOV  R1, 0
    MOV  [localizacao_meteoro], R1     ; mete os valores do missil como original 
    CALL meteoro_aleatorio             ; vai meter outro meteoro no ecrã; vai meter outro meteoro no ecrã

sai_colisoes:
    POP R11
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; **********************************************************************
; Converte - traz o valor de hexa para decimal
; 
; Argumentos:	
;		R10- valor do display em hexa
;
; Devolve: Valor do display em decimal
; **********************************************************************

converte:
	PUSH R0
   	PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5

    MOV R4, DISPLAYS
    MOV R5, INICIAL
    MOV R0, R10                         ; R10 é o valor da energia guardado em memoria
    MOV R1, R10	                        ; guarda também o valor de energia em R1
    DIV R0, R5                          ; R10 // 100
    MOD R1, R5                          ; R10 % 100
    SHL R0, 4                           ; R0 será o algarismo das centenas
    MOV R2, 10                          
    MOV R3, R1                      
    DIV R1, R2                          ; R1 (resto) // 10
    OR  R0, R1
    SHL R0, 4                           ; R1 será o algarismo das dezenas
    MOD R3, R2                          ; R3 (=R1) % 10
    OR  R0, R3                          ; R3 será o algarismo das unidades 
    MOV [R4], R0                        ; escreve o valor no display

    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


