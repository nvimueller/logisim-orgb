= SLTIU Monociclo

usar subtração normal da ULA
setar flags pela memória de baixo
mais importante: mux que seleciona se registrador destino vai receber a flag de instrução ou o próprio resultado da subtração implementado por meio da func3 da SLTIU. se for igual a 011, rd recebe a flag (1 ou 0), senão, recebe o resultado da ULA mesmo
