= LUI Monociclo

ajuste no gerador de imediatos para isolar os 20 bits mais significativos da instrução e preencher com 12 zeros à direita (formato U).
configuração do controle na ROM para forçar uma soma normal na ULA, ativar o uso do imediato (alusrc) e permitir a escrita (regwrite).
mais importante: adição de um mux na entrada superior da ULA, controlado por um comparador do opcode da LUI (0x37). se a instrução for LUI, esse mux injeta uma constante 0 para a ULA somar com o imediato, senão, deixa passar a leitura normal do registrador 1.

= LUI Multiciclo

modificação no datapath aproveitando o mux já existente na entrada superior da ULA (alusrca), conectando apenas uma constante 0 numa de suas portas livres.
programação da ROM de próximo estado para reconhecer o opcode 0x37 na fase de decodificação (estado 01) e desviar o fluxo para dois novos estados (08 e 09).
mais importante: programação da ROM de saída para orquestrar os sinais no tempo. o estado de execução (08) aciona os muxes para injetar o 0 e o imediato na ULA forçando uma soma; o estado de writeback (09) isola a gravação, ativando apenas o regwrite para salvar o valor do aluout no registrador destino.

= SLTIU Monociclo

usar subtração normal da ULA
setar flags pela memória de baixo
mais importante: mux que seleciona se registrador destino vai receber a flag de instrução ou o próprio resultado da subtração implementado por meio da func3 da SLTIU. se for igual a 011, rd recebe a flag (1 ou 0), senão, recebe o resultado da ULA mesmo

= SLTIU Multiciclo

modificação das memórias para suportar a nova instrução
mux parecido com o de monociclo para passar a flag, a menos de um sinal do estado atual ser maior que 1, porque estava gerando erro na incrementação do pc no estado 0, pois o func3 permanecia ainda

= SLTIU Pipeline

mudança igual a do monociclo, pois sinais são iguais
