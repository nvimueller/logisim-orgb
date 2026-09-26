= LUI Monociclo

ajuste no gerador de imediatos para isolar os 20 bits mais significativos da instrução e preencher com 12 zeros à direita (formato U).
configuração do controle na ROM para forçar uma soma normal na ULA, ativar o uso do imediato (alusrc) e permitir a escrita (regwrite).
mais importante: adição de um mux na entrada superior da ULA, controlado por um comparador do opcode da LUI (0x37). se a instrução for LUI, esse mux injeta uma constante 0 para a ULA somar com o imediato, senão, deixa passar a leitura normal do registrador 1.

= LUI Multiciclo

modificação no datapath aproveitando o mux já existente na entrada superior da ULA (alusrca), conectando apenas uma constante 0 numa de suas portas livres.
programação da ROM de próximo estado para reconhecer o opcode 0x37 na fase de decodificação (estado 01) e desviar o fluxo para dois novos estados (08 e 09).
mais importante: programação da ROM de saída para orquestrar os sinais no tempo. o estado de execução (08) aciona os muxes para injetar o 0 e o imediato na ULA forçando uma soma; o estado de writeback (09) isola a gravação, ativando apenas o regwrite para salvar o valor do aluout no registrador destino.

= LUI Pipeline

expansão da largura da ROM no bloco de controle de 8 para 9 bits para criar o novo sinal de controle exclusivo LUIsel durante o estágio de decodificação (ID) ao identificar o opcode 0x37.
roteamento minucioso dos fios no separador da barreira ID/EX para respeitar o fluxo do pipeline. os sinais de execução (ALUOp e ALUSrc) foram isolados para morrerem no estágio EX, o novo sinal LUIsel foi puxado para comandar a entrada da ULA no mesmo estágio, e os sinais de memória e writeback foram agrupados num novo separador para continuarem a viagem até ao registrador EX/MEM.
modificação do datapath no estágio de execução (EX) com a inserção de um novo mux na entrada superior da ULA. comandado pelo sinal LUIsel que viajou pela barreira, este mux passa a injetar uma constante 0 para a LUI ou permite a passagem normal do valor do registrador rs1 para as restantes operações matemáticas.

= SLTIU Monociclo

usar subtração normal da ULA
setar flags pela memória de baixo
mais importante: mux que seleciona se registrador destino vai receber a flag de instrução ou o próprio resultado da subtração implementado por meio da func3 da SLTIU. se for igual a 011, rd recebe a flag (1 ou 0), senão, recebe o resultado da ULA mesmo

= SLTIU Multiciclo

modificação das memórias para suportar a nova instrução
mux parecido com o de monociclo para passar a flag, a menos de um sinal do estado atual ser maior que 1, porque estava gerando erro na incrementação do pc no estado 0, pois o func3 permanecia ainda

= SLTIU Pipeline

mudança igual a do monociclo, pois sinais são iguais

= JALR Monociclo

Coloquei um MUX novo logo antes do PC pra ele poder receber o endereço do salto direto da ALU (rs1 + imediato).
Coloquei outro MUX lá na entrada de dados do banco de registradores pra conseguirmos salvar o PC + 4 no registrador destino.
No bloco de controle, criei uma flag nova chamada jalr_sel que aciona esses dois MUXes ao mesmo tempo.
Pra fazer isso caber, tive que aumentar os splitters e a ROM de controle pra 9 bits. O valor na ROM pro opcode do JALR (endereço 67) ficou 1c0 (que liga o nosso jalr_sel, o regwrite e o alusrc pra pegar o imediato).

= JALR Multiciclo
programação da ROM de próximo estado para reconhecer o opcode 0x67 na fase de decodificação (estado 01) e desviar o fluxo para dois novos estados livres (0B e 0C).
configuração da ROM de geração de saída para orquestrar os sinais, ativando a soma da ULA e a escrita no PC no estado de execução (0B), e o regwrite no estado de writeback (0C). 
mais importante: modificação no bloco operativo com a adição de um segundo mux logo antes da entrada de dados do banco de registradores para encaminhar o endereço de retorno (oldpc). 
a seleção desse mux é feita de forma combinacional por um comparador focado exclusivamente no opcode do JALR (0x67), garantindo que as instruções originais continuem a funcionar normalmente.

