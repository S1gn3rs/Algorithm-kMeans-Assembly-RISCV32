#
# IAC 2023/2024 k-means
#
# Grupo: 33
# Campus: Alameda
#
# Autores:
# 106823, Guilherme Silva
# 109324, Joao Agostinho
#
# Tecnico/ULisboa

# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data.
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
# centroids:   .word 0,0
# k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 24,31, 15,15
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outrasestruturas de dados
# que o grupo considere necessarias para a solucao:

#OPTIMIZATION
# O cluster associado a cada ponto eh guardado em um byte na stack por forma
# a dinamizar a atribuicao dos clusters aos pontos.

clusters:     .zero 4 # Endereco na stack para os valores de cluster dos ponto

randomSeed: .zero 4 # Seed usada para gerar o proximo numero aleatorio

# Mensagens das funcoes

str_cleanScreen: .string "A desligar as leds do ecra.\n"

str_randomCentroids: .string "A calcular centroids pseudo-aleatorios.\n"

str_calculateClusters: .string "A calcular os clusters.\n"

str_calculateCentroids: .string "A calcular os centroids.\n"

str_printClusters: .string "A ligar as leds dos clusters.\n"

str_printCentroids: .string "A ligar as leds dos centroids.\n"

str_iteracoesUsadas1: .string "Foram feitas "

str_iteracoesUsadas2: .string " iteracoes.\n"

#Definicoes de cores a usar no projeto

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff


# Codigo

.text

    jal mainKMeans

    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra


### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t0 LED_MATRIX_0_HEIGHT # Altura da matriz de leds
    li t1 LED_MATRIX_0_WIDTH  # Comprimento da matriz de leds
    mul t0 t0 t1              # Quantidade total de leds
    slli t0 t0 2              # Quantidade total de bytes das leds

    li t1 LED_MATRIX_0_BASE   # Endereco do primeiro elemento da matriz
    add t0 t0 t1              # Endereco limite + 4 bytes
    addi t0 t0 -4             # Endereco limite

    li t2 white               # Inicializacao da cor branca
    for_cleanScreen: bge t1 t0 endFor_cleanScreen
                              # Acaba quando atinge endereco limite
        sw t2 0(t1)           # 1o led de 4 colocado a branco
        sw t2 4(t1)           # 2o led de 4 colocado a branco
        sw t2 8(t1)           # 3o led de 4 colocado a branco
        sw t2 12(t1)          # 4o led de 4 colocado a branco
        addi t1 t1 16         # Incrementa 16 bytes no endereco

        j for_cleanScreen     # Volta ao inicio do loop

    endFor_cleanScreen: jr ra # Retorna para a chamada da funcao


### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    addi sp sp -32            # Guarda os valores dos registos na stack
    sw a0 0(sp)               # Guarda valor do registo a0
    sw a1 4(sp)               # Guarda valor do registo a1
    sw a2 8(sp)               # Guarda valor do registo a2
    sw s0 12(sp)              # Guarda valor do registo s0
    sw s1 16(sp)              # Guarda valor do registo s1
    sw s2 20(sp)              # Guarda valor do registo s2
    sw s3 24(sp)              # Guarda valor do registo s3
    sw ra 28(sp)              # Guarda valor do registo ra

    lw s0 n_points            # Numero de pontos
    la s1 points              # Endereco do primeiro ponto

    slli s0 s0 3              # Cada coordenada com 8 bytes de tamanho (x,y)
    add s0 s1 s0              # Ultimo elemento da lista mais 8 bytes
    la s2 colors              # Endereco da primeira cor

    lw s3 clusters            # Endereco do vetor dos clusters de cada ponto

    for_printClusters: beq s0 s1 endFor_printClusters
                              # Se s0 == s1, (inicio da lista) encerra o loop
        addi s3 s3 -1         # Decrementa 1 byte no endereco
        addi s0 s0 -8         # Decrementa 8 bytes no endereco

        lb a0 0(s3)           # (Numero do cluster atribuido a cada ponto) * 4
        add a2 s2 a0          # Endereco da cor corresponte ao cluster do ponto
        lw a2 0(a2)           # Cor correspondente ao cluster do ponto

        lw a0 0(s0)           # Coordenada x
        lw a1 4(s0)           # Coordenada y
        jal printPoint        # Coloca cor na coordenada(x,y)

        j for_printClusters   # Salta para o inicio do loop

    endFor_printClusters:     # Restaura da stack os valores antigos dos registos
    lw a0 0(sp)               # Restaura valor do registo a0
    lw a1 4(sp)               # Restaura valor do registo a1
    lw a2 8(sp)               # Restaura valor do registo a2
    lw s0 12(sp)              # Restaura valor do registo s0
    lw s1 16(sp)              # Restaura valor do registo s1
    lw s2 20(sp)              # Restaura valor do registo s2
    lw s3 24(sp)              # Restaura valor do registo s3
    lw ra 28(sp)              # Restaura valor do registo ra
    addi sp sp 32             # Restaura o valor do endereco da stack

    jr ra                     # Retorna para a chamada da funcao


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos:
# a0: Cor que sera utilizada para pintar os centroids
# Retorno: nenhum

printCentroids:
    addi sp sp -20            # Guarda os valores dos registos na stack
    sw a1 0(sp)               # Guarda valor do registo a1
    sw a2 4(sp)               # Guarda valor do registo a2
    sw s0 8(sp)               # Guarda valor do registo s0
    sw s1 12(sp)              # Guarda valor do registo s1
    sw ra 16(sp)              # Guarda valor do registo ra

    lw s0 k                   # Numero de centroids
    slli s0 s0 3              # Numero de centroids * 8
    la s1 centroids           # Endereco dos centroids
    add s0 s1 s0              # Fim da lista de centroids + 8
    mv a2 a0                  # Cor dos centroids e colocada em a2
    for_printCentroids: beq s0 s1 endFor_printCentroids
                              # Se s0 == s1, (inicio da lista) encerra o loop
        addi s0 s0 -8         # Decrementa 8 bytes no endereco
        lw a0 0(s0)           # Coordenada x centroid
        lw a1 4(s0)           # Coordenada y centroid
        jal printPoint        # Pinta de preto a coordenada (x,y) do centroid
        j for_printCentroids  # Salta para o inicio do loop

    endFor_printCentroids:
                              # Restaura da stack os valores antigos dos registos
    lw a1 0(sp)               # Restaura valor do registo a1
    lw a2 4(sp)               # Restaura valor do registo a2
    lw s0 8(sp)               # Guarda valor do registo s0
    lw s1 12(sp)              # Guarda valor do registo s1
    lw ra 16(sp)              # Restaura valor do registo ra
    addi sp sp 20             # Restaura o valor do endereco da stack

    jr ra                     # Retorna para a chamada da funcao


### calculateCentroids
# Calcula os k centroids, a partir da distribuicao atual de pontos
# associados a cada agrupamento (cluster) e limpa do ecra os centroids anteriores
# Argumentos: nenhum
# Retorno:
# a0: Retorna 0 se os centroids obtidos forem iguais aos anteriores, caso
# contrario retorna a soma do quadrado das variacoes de coord. de cada centroid

calculateCentroids:
    #-----------------------------------------------------------------------------
    #--Eh criada uma estrutura na stack que guarda para cada cluster a soma dos --
    #---coordenadas x, y e tambem a quantidade de pontos em cada cluster ---------
    #-----------------------------------------------------------------------------
    addi sp sp -8
    sw s0 0(sp)              # Guarda valor do registo s0
    sw ra 4(sp)              # Guarda valor do registo ra

    mv t0 sp                 # Obtem na stack o endereco para o vetor
    lw t1 k                  # Valor de k
    li t2 12                 # 12 bytes necessarios, (x,y,quantidade)
    mul t1 t1 t2             # Tamanho necessario para o vetor (12 * k)
    sub sp sp t1             # Reservar na stack o espaco para a estrutura

    # Limpa valores antigos na memoria, colocando-os a 0 para poder incrementa-los
    mv t1 t0                 # Guardar em t1 o endereco do vetor

    for_calculateCentroids: beq t1 sp endFor_calculateCentroids
                             # Se t1 == sp, (fim do vetor) encerra o loop
        addi t1 t1 -12       # Decrementa 12 bytes no endereco  (x,y,quantidade)
        sw x0 0(t1)          # Inicializar a 0 a posicao no vetor da soma dos x
        sw x0 4(t1)          # Inicializar a 0 a posicao no vetor da soma dos y
        sw x0 8(t1)          # Inicializar a 0 a posicao no vetor da quant. pontos
                             # Volta ao inicio do loop
        j for_calculateCentroids

    endFor_calculateCentroids:

    #-----------------------------------------------------------------------------
    #--A estrutura eh atualizada com a soma dos coordenadas e quantidade de pontos
    #-----------------------------------------------------------------------------
    addi t0 t0 -12            # Estrutura aponta para as informacoes do 1o cluster

    lw t1 clusters            # Vetor dos clusters de cada ponto
    lw t2 n_points            # Numero de pontos
    slli t2 t2 3              # Numero de pontos * 8 (bytes do vetor cluster)
    la t3 points              # Vetor de pontos
    add t2 t3 t2              # Final do vetor de pontos + 8

    li a0 3                   # Guardar o valor 3 em a0 (valor para multiplicar)

    for_calculateCentroids_1: beq t2 t3 endFor_calculateCentroids_1
                              # Se t2 == t3, (inicio da lista) encerra o loop
        addi t2 t2 -8         # Decrementa 8 bytes no endereco dos pontos
        addi t1 t1 -1         # Decrementa 1 byte no endereco dos clusters
        lb t4 0(t1)           # Cluster do ponto * 4
        mul t4 t4 a0          # Cluster do ponto * 3, (numero de bytes a pular)
        sub t0 t0 t4          # A estrutura eh posicionada na posicao desejada,
                              # respetiva ao cluster do ponto que vamos adicionar

        lw t5 0(t2)           # Valor de x do ponto
        lw t6 0(t0)           # Soma dos x anteriores do cluster na estrutura
        add t5 t6 t5          # Eh adicionado o x obtido a soma
        sw t5 0(t0)           # Guarda-se nova soma dos x obtida na estrutura

        lw t5 4(t2)           # Valor de y do ponto
        lw t6 4(t0)           # Soma dos y anteriores do cluster na estrutura
        add t5 t6 t5          # Eh adicionado o y obtido na soma
        sw t5 4(t0)           # Guarda-se nova soma dos y obtida na estrutura

        lw t5 8(t0)           # Valor da quantidade de pontos do cluster
        addi t5 t5 1          # Eh adicionado ah contagem de pontos no cluster
        sw t5 8(t0)           # O novo valor da contagem eh guardado na estrutura
        add t0 t0 t4          # Estrutura reposta na posicao original (1o cluster)

                              # Volta ao inicio do loop
        j for_calculateCentroids_1

    endFor_calculateCentroids_1:
    addi t0 t0 12             # Volta-se a colocar vetor da estrutura a apontar
                              # para a posicao original

    #-----------------------------------------------------------------------------
    #--- Os centroids anteriores sao colocados a branco(limpos do ecra)
    #-----------------------------------------------------------------------------

    #OPTIMIZATION
    # Eh apenas necessario limpar os centroids, uma vez sao os unicos pontos
    # que mudam de coordenadas. Para tornar o codigo mais eficiente e mazimizar
    # o tempo que os centroids estao no ecra, ao calcularmos os novos centroids,
    # na propria funcao limpamos os antigos centroids.
    mv s0 t0                  # Guardar o endereco da estrutura
    li a0 white               # Cor branca para limpar os pontos anteriores
    jal printCentroids        # Invoca a funcao printCentroids
    mv t0 s0                  # Receber o endereco da estrutura


    #-----------------------------------------------------------------------------
    #---Com os os dados obtidos na estrutura calcula-se novos centroids ----------
    #-----------------------------------------------------------------------------
    la t1 centroids           # Vetor com as coordenadas dos centroids
    mv t6 t0                  # Eh guardada a posicao original da estrutura em t6
    li a0 0                   # Caso coordenada seja alterada a0 deixa de ser 0
    for_calculateCentroids_2: beq t0 sp endFor_calculateCentroids_2
                              # Se t0 == sp, (inicio da lista) encerra o loop
    addi t0 t0 -12            # Decrementa 12 bytes no endereco da estrutura
    lw t3 8(t0)               # Numero de pontos no cluster de cada centroid
    beqz t3 increment_calculateCentroids
                              # Se o numero de pontos do cluster for zero nao se
                              # calcula um novo centroid
    lw t4 0(t0)               # Soma dos valores de X do cluster
    div t4 t4 t3              # Media dos valores de X do cluster
    lw t5 0(t1)               # Valor de X do centroid original

    sub t5 t4 t5              # Subtrai-se o valor novo com o antigo
    mul t5 t5 t5              # Quadrado para todas as variacoes ficarem positivas
    add a0 t5 a0              # Adiciona-se a a0 a esta variacao
    sw t4 0(t1)               # Guardar o novo valor de X

    lw t4 4(t0)               # Soma dos valores de Y do cluster
    div t4 t4 t3              # Media dos valores de Y do cluster
    lw t5 4(t1)               # Valor de Y do centroid original

    sub t5 t4 t5              # Subtrai-se o valor novo com o antigo
    mul t5 t5 t5              # Quadrado para todas as variacoes ficarem positivas
    add a0 t5 a0              # Adiciona-se a a0 a variacao se esta variacao
    sw t4 4(t1)               # Guardar o novo valor de Y

    increment_calculateCentroids:
    addi t1 t1 8             # Incrementa 12 bytes no endereco da estrutura
                             # Volta ao inicio do loop
    j for_calculateCentroids_2
    endFor_calculateCentroids_2:
    mv sp t6                  # Retira a estrutura da stack

    lw s0 0(sp)               # Guarda valor do registo s0
    lw ra 4(sp)               # Guarda valor do registo ra
    addi sp sp 8              # Restaura o valor do endereco da stack
    jr ra                     # Retorna para a chamada da funcao


### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:            # |x0 - x1| + |y0 - y1|
    sub a0 a0 a2              # Diferenca entre os valores de x  |x0 - x1|
    bgez a0 x_posi_manhattan  # Se a diferenca dos valores x for positiva, salta
    neg a0 a0                 # A difereca negativa eh passada a positiva
    x_posi_manhattan:
    sub a1 a1 a3              # Diferenca entre os valores de y |y0 - y1|
    bgez a1 y_posi_manhattan  # Se a diferenca dos valores y for positiva, salta
    neg a1 a1                 # A difereca negativa eh passada a positiva
    y_posi_manhattan:
    add a0 a0 a1              # Soma das distancias entre os x e os y
    jr ra                     # Retorna para a chamada da funcao


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    addi sp sp -36            # Guarda os valores dos registos na stack
    sw s0 0(sp)               # Guarda valor do registo s0
    sw s1 4(sp)               # Guarda valor do registo s1
    sw s2 8(sp)               # Guarda valor do registo s2
    sw s3 12(sp)              # Guarda valor do registo s3
    sw s4 16(sp)              # Guarda valor do registo s4
    sw s5 20(sp)              # Guarda valor do registo s5
    sw a2 24(sp)              # Guarda valor do registo a2
    sw a3 28(sp)              # Guarda valor do registo a3
    sw ra 32(sp)              # Guarda valor do registo ra

    lw s0 k                   # Numero de centroids
    slli s0 s0 3              # Cada coordenada com 8 bytes de tamanho (x,y) 
    la s1 centroids           # Carrega o endereco dos centroids
    add s2 s1 s0              # Endereco do ultimo ponto + 8

    mv s3 a0                  # Guarda a coordenada x do ponto em s3
    mv s4 a1                  # Guarda a coordenada y do ponto em s4

    li s5 0x7FFFFFFF          # Valor maximo carregavel (distancia menor atual)

    for_nearestCluster: beq s1 s2 endFor_nearestCluster
                              # Se s1 == s2, (inicio da lista) encerra o loop 
        addi s2 s2 -8         # Decrementa 8 bytes no endereco
        mv a0 s3              # Guarda a coordenada x do ponto em a0
        mv a1 s4              # Guarda a coordenada y do ponto em a1
        lw a2 0(s2)           # Guarda a coordenada x dos centroids em a2
        lw a3 4(s2)           # Guarda a coordenada y dos centroids em a3
        jal manhattanDistance # Calcula a distancia de manhattan
        bgt a0 s5 for_nearestCluster
                              # Se a distancia calculada eh a menor de todas
        mv s5 a0              # A menor distancia total passa a ser a calculada
        sub s0 s2 s1          # Atualiza-se o index do centroid mais proximo
        j for_nearestCluster  # Volta ao inicio do loop

    endFor_nearestCluster:
    srli s0 s0 3               # Obtem o index ao dividir por 8
    mv a0 s0                   # Coloca o output em a0

    lw s0 0(sp)                # Restaura valor do registo s0
    lw s1 4(sp)                # Restaura valor do registo s1
    lw s2 8(sp)                # Restaura valor do registo s2
    lw s3 12(sp)               # Restaura valor do registo s3
    lw s4 16(sp)               # Restaura valor do registo s4
    lw s5 20(sp)               # Restaura valor do registo s5
    lw a2 24(sp)               # Restaura valor do registo a2
    lw a3 28(sp)               # Restaura valor do registo a3
    lw ra 32(sp)               # Restaura valor do registo ra
    addi sp sp 36              # Restaura o valor do endereco da stack

    jr ra                      # Retorna para a chamada da funcao


############################## FUNCOES AUXILIARES ################################
                                                                                 #
### xorShift                                                                     #
# Gera um numero pseudo-aleatorio aplicando o algoritmo xorShift.                #
# Argumentos: nenhum                                                             #
# Retorno:                                                                       #
# a0: numero psudo-aleatorio de 32 bits                                          #
                                                                                 #
xorShift:                                                                        #
                                                                                 #
    lw a0 randomSeed          # Seed pseudo-aleatoria                            #
                                                                                 #
                              # seed = seed ^ (seed >> 13)                       #
    li t0 13                  # numero de bits que vao levar shift (13 bits)     #
    srl t1 a0 t0              # guarda em t1 o a0 com o shift para a direita     #
    xor a0 a0 t1              # guarda em a0 o resultado xor de a0 e t1          #
                                                                                 #
                              # seed = seed ^ (seed << 17)                       #
    li t0 17                  # numero de bits que vao levar shift (17 bits)     #
    sll t1 a0 t0              # guarda em t1 o a0 com o shift para a esquerda    #
    xor a0 a0 t1              # guarda em a0 o resultado xor de a0 e t1          #
                                                                                 #
                              # seed = seed ^ (seed >> 5)                        #
    li t0 5                   # numero de bits que vao levar shift (5 bits)      #
    srl t1 a0 t0              # guarda em t1 o a0 com o shift para a direita     #
    xor a0 a0 t1              # guarda em a0 o resultado xor de a0 e t1          #
                                                                                 #
    la t0 randomSeed          # Endereco da seed pseudo-aleatoria                #
    sw a0 0(t0)               # Guarda o novo valor da seed                      #
                                                                                 #
    jr ra                     # Retorna para a chamada da funcao                 #
                                                                                 #
                                                                                 #
### getRandomCoord                                                               #
# Gera uma coordenada (x,y) pseudo-aleatoria pertencente ah matriz.              #
# Argumentos: nenhum                                                             #
# Retorno:                                                                       #
# a0: coordenada pseudo-aleatoria x                                              #
# a1: coordenada pseudo-aleatoria y                                              #
                                                                                 #
#Nota: Foi exemplificado nos comentarios para melhor percecao largura de 32 leds #
                                                                                 #
getRandomCoord:                                                                  #
    addi sp sp -8             # Decrementa 8 bytes no endereco da stack          #
    sw s0 0(sp)               # Guarda valor do registo s0                       #
    sw ra 4(sp)               # Guarda valor do registo ra                       #
                                                                                 #
    li s0 LED_MATRIX_0_WIDTH  # quantidade de colunas/linha da matriz (0-31)     #
                                                                                 #
                              # Coordenada y                                     #
    jal xorShift              # Obtem numero pseudo-aleatorio                    #
    remu a1 a0 s0             # Reduz o numero aleatorio em numero entre 0 e 31  #
                              # Coordenada x                                     #
    jal xorShift              # Obtem numero pseudo-aleatorio                    #
    remu a0 a0 s0             # Reduz o numero aleatorio em numero entre 0 e 31  #
                                                                                 #
    lw s0 0(sp)               # Restaura valor do registo s0                     #
    lw ra 4(sp)               # Restaura valor do registo ra                     #
    addi sp sp 8              # Restaura o valor do endereco da stack            #
                                                                                 #
    jr ra                     # Retorna para a chamada da funcao                 #
                                                                                 #
                                                                                 #
### randomCentroids                                                              #
# Coloca novas coordenadas pseudo-aleatorias nas coordenadas dos centroids.      #
# Argumentos: nenhum                                                             #
# Retorno: nenhum                                                                #
                                                                                 #
randomCentroids:                                                                 #
    addi sp sp -12            # Decrementa 12 bytes no endereco da stack         #
    sw s0 0(sp)               # Guarda valor do registo s0                       #
    sw s1 4(sp)               # Guarda valor do registo s1                       #
    sw ra 8(sp)               # Guarda valor do registo ra                       #
                                                                                 #
    la s0 centroids           # Endereco dos centroids                           #
    lw s1 k                   # Quantidade de centroids                          #
    slli s1 s1 3              # quantidade de centroids * 8 (em bytes)           #
    add s1 s1 s0              # Endereco do ultimo centroid mais 8               #
                                                                                 #
    for_randomCentroids: beq s0 s1 endFor_getRandomCentroids                     #
                              # Se s0 == s1, (inicio da lista) termina o loop    #
        addi s1 s1 -8         # Decrementa 8 bytes no endereco                   #
        jal getRandomCoord    # Obtem coordenadas pseudo-aleatorias (x,y)        #
        sw a0 0(s1)           # Guarda a coordenada x na coordenada do cluster   #
        sw a1 4(s1)           # Guarda a coordenada y na coordenada do cluster   #
        j for_randomCentroids # Volta ao inicio do loop                          #
                                                                                 #
    endFor_getRandomCentroids:                                                   #
    lw s0 0(sp)               # Restaura valor do registo s0                     #
    lw s1 4(sp)               # Restaura valor do registo s1                     #
    lw ra 8(sp)               # Restaura valor do registo ra                     #
    addi sp sp 12             # Restaura o valor do endereco da stack            #
                                                                                 #
    jr ra                     # Retorna para a chamada da funcao                 #
                                                                                 #
                                                                                 #
### calculateClusters                                                            #
# Atualiza o vetor de clusters com o index * 4 do centroid mais proximo          #
# de cada ponto                                                                  #
# Argumentos: nenhum                                                             #
# Retorno: nenhum                                                                #
calculateClusters:                                                               #
                                                                                 #
    addi sp sp -24            # Decrementa 8 bytes no endereco da stack          #
    sw ra 0(sp)               # Guarda valor do registo ra                       #
    sw s0 4(sp)               # Guarda valor do registo s0                       #
    sw s1 8(sp)               # Guarda valor do registo s1                       #
    sw s2 12(sp)              # Guarda valor do registo s2                       #
    sw a0 16(sp)              # Guarda valor do registo a0                       #
    sw a1 20(sp)              # Guarda valor do registo a1                       #
                                                                                 #
    lw s0 clusters            # Endereco na stack dos clusters de cada ponto     #
    lw s1 n_points            # Numero de pontos                                 #
    slli s1 s1 3              # Numero de pontos * 8                             #
    la s2 points              # Vetor de pontos                                  #
    add s1 s2 s1              # Final do vetor de pontos + 8                     #
                                                                                 #
    for_calculateClusters: beq s1 s2 endFor_calculateClusters                    #
                              # Se s1 == s2, (inicio da lista) encerra o loop    #
        addi s1 s1 -8         # Decrementa 8 bytes no endereco                   #
        addi s0 s0 -1         # Decrementa 1 byte no endereco                    #
                                                                                 #
        lw a0 0(s1)           # Coloca a coordenada x do ponto em a0             #
        lw a1 4(s1)           # Coloca a coordenada y do ponto em a1             #
        jal nearestCluster    # Busca o index do cluster mais proximo desse ponto#
                                                                                 #
        slli a0 a0 2          # Multiplica o index por 4                         #
        sb a0 0(s0)           # Guarda o index no vetor de clusters              #
                                                                                 #
                              # Volta ao inicio do loop                          #
        j for_calculateClusters                                                  #
                                                                                 #
    endFor_calculateClusters:                                                    #
    lw ra 0(sp)               # Restaura valor do registo ra                     #
    lw s0 4(sp)               # Restaura valor do registo s0                     #
    lw s1 8(sp)               # Restaura valor do registo s1                     #
    lw s2 12(sp)              # Restaura valor do registo s2                     #
    lw a0 16(sp)              # Restaura valor do registo a0                     #
    lw a1 20(sp)              # Restaura valor do registo a1                     #
    addi sp sp 24             # Restaura o valor do endereco da stack            #
                                                                                 #
    jr ra                     # Retorna para a chamada da funcao                 #
                                                                                 #
                                                                                 #
##################################################################################

### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    #---------- Inicializacao dos clusters -------------------------------
    la t0 clusters            # Endereco do vetor dos cluster de cada ponto
    sw sp 0(t0)               # Guardar o endereco do inicio dos clusters
    lw t0 n_points            # Numero de pontos dos clusters
    sub sp sp t0              # Stack Pointer n_points bytes a menos
    #---------------------------------------------------------------------
    addi sp sp -20            # Decrementa 16 bytes no endereco da stack
    sw a0 0(sp)               # Guarda valor do registo a0
    sw a1 4(sp)               # Guarda valor do registo a1
    sw a7 8(sp)               # Guarda valor do registo a7
    sw s0 12(sp)              # Guarda valor do registo s0
    sw ra 16(sp)              # Guarda valor do registo ra

    li a7 30                  # 30 para guardar o valor dos milisseg. em a0 e a1
    ecall                     # Guarda os valores em a0 e a1
    la t0 randomSeed          # Endereco da seed com valor inicial a zero
    sw a0 0(t0)               # Guarda na seed o valor atual dos milissegundos

    li a7 4                   # 4 para conseguir dar print de strings

    #1. randomCentroids
    la a0 str_randomCentroids
    ecall                     # Print da mensagem do cleanScreen
    jal randomCentroids       # Invoca a funcao randomCentroids

    #OPTIMIZATION
    # Apenas realiza-se um cleanScreen no inicio do algoritmo, sendo apenas 
    # necessario limpar os centroids, uma vez sao os unicos pontos que mudam de
    # coordenadas. Logo, por razoes de eficiencia nao e preciso o cleanScreen
    # dentro do loop.
    #2. cleanScreen
    la a0 str_cleanScreen
    ecall                     # Print da mensagem do cleanScreen
    jal cleanScreen           # Invoca a funcao cleanScreen

    lw s0 L                   # Numero de iteracoes do for loop
    for_mainKMeans: beqz s0 endFor_mainKMeans
                              # Se s0 == 0, (fim das iteracoes) encerra o loop 
        addi s0 s0 -1         # Remove uma iteracao do for loop

        #3. calculateClusters
        la a0 str_calculateClusters
        ecall                 # Print da mensagem do calculateClusters
        jal calculateClusters # Invoca a funcao calculateClusters

        #4. printClusters
        la a0 str_printClusters
        ecall                 # Print da mensagem do printClusters
        jal printClusters     # Invoca a funcao printClusters

        #5. printCentroids
        la a0 str_printCentroids
        ecall                 # Print da mensagem do printCentroids
        li a0 black           # Cor preta
        jal printCentroids    # Invoca a funcao printCentroids

        #6. calculateCentroids
        la a0 str_calculateCentroids
        ecall                  # Print da mensagem do calculateCentroids
        jal calculateCentroids # Invoca a funcao calculateCentroids
        beqz a0 endFor_mainKMeans
                               # Caso a0 == 0, nao houve mudanca dos centroids
        j for_mainKMeans       # Volta ao inicio do loop

    endFor_mainKMeans:

    la a0 str_printCentroids
    ecall                     # Print da mensagem do printCentroids
    li a0 black               # Cor preta
    jal printCentroids        # Invoca a funcao printCentroids

    la a0 str_iteracoesUsadas1
    ecall                     # Primeira parte da mensagem de iteracoes

    lw a0 L                   # Quantidade maxima de iteracoes
    sub a0 a0 s0              # Coloca em a0 a quantidade feita de iteracoes

    li a7 1                   # 1 para conseguir dar print a inteiros
    ecall                     # Print da quantidade de iteracoes feitas

    li a7 4                   # 4 para conseguir dar print a strings
    la a0 str_iteracoesUsadas2
    ecall                     # Segunda parte da mensagem de iteracoes

    lw a0 0(sp)               # Restaura valor do registo a0
    lw a1 4(sp)               # Restaura valor do registo a1
    lw a7 8(sp)               # Restaura valor do registo a7
    lw s0 12(sp)              # Restaura valor do registo s0
    lw ra 16(sp)              # Restaura valor do registo ra
    addi sp sp 20             # Restaura o valor do endereco da stack

    lw sp clusters            # Restaura o valor original do endereco da stack

    #7. termina
    jr ra                     # Retorna para a chamada da funcao 
