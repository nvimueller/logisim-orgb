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

= DIV Monociclo

adição de um divisor com sinal na ULA, ligado na entrada 3 do mux de operações, que estava livre. os operandos e o resultado chegam por túneis (divA, divB e divQ) para não mexer na fiação que já existia.
como o divisor do logisim só faz divisão sem sinal, o circuito tira o módulo dos dois operandos (negador + comparador com 0 + mux), divide, e nega o quociente quando os sinais de A e B são diferentes (comparador de 1 bit nos bits de sinal).
mais importante: tratamento dos casos especiais da especificação. a divisão por zero devolve -1 (0xFFFFFFFF) por meio de um mux final controlado pelo comparador B == 0, e o resultado é truncado em direção a zero (-7 / 2 = -3). o caso -2^31 / -1 também sai certo, dando -2^31.
no controle da ULA, adição de um mux no caminho do tipo R (aluop 10) que gera o código 3 quando o funct3 é 100 e o funct7[0] é 1, que é a marca das instruções da extensão M.
a ROM de controle não precisou de mudança, porque o div usa o mesmo opcode do tipo R (0x33).

= DIV Multiciclo

mudança igual à do monociclo na ULA e no controle da ULA, pois os blocos são os mesmos.
programação da ROM de próximo estado para o tipo R (opcode 0x33), que estava faltando: busca (00), decodificação (01), execução (06) e writeback (07). como o divisor é combinacional, ele cabe no estado de execução normal.

= DIV Pipeline

mudança igual à do monociclo na ULA e no controle da ULA.
adição da entrada do tipo R (0x33) na ROM de controle com o valor 082 (regwrite e aluop 10), que não existia. o divisor fica todo dentro do estágio EX.

= Correções Monociclo

o addi usava aluop 01, que o controle da ULA transforma em subtração. a ROM passou a usar aluop 00 (soma) no opcode 0x13.
o bit jalr_sel (bit 8) estava ligado também no load, no addi, no tipo R e no LUI, o que fazia essas instruções saltarem. ele ficou ligado só no JALR.
a entrada do JALR na ROM estava no endereço 0x66 (102), mas o opcode do JALR é 0x67 (103). o valor 1c0 foi movido para o endereço certo.
mais importante: três fios do JALR estavam em lugares errados. a saída do mux antes do PC terminava 10 px acima da entrada D do registrador, deixando o PC sem entrada. a entrada 1 desse mux estava ligada na saída "menor que" da ULA (a mesma do SLTIU), e não no resultado. e o mux de dados do banco de registradores recebia a constante 4, e não o PC + 4. os dois últimos foram religados por túneis (resultado_ula e pc_mais_4).
o SLTIU olhava só o funct3 == 011, que no LUI faz parte do imediato. foi adicionada uma porta AND com a negação do comparador de opcode do LUI (túnel e_lui) antes do seletor do mux.

= Correções Multiciclo

as entradas de load, store, tipo R e branch na ROM de próximo estado estavam no formato opcode\<\<4, mas o endereço é opcode\<\<8 | estado. elas foram movidas para o formato certo, e foram adicionadas as transições da busca (estado 00) para cada opcode, incluindo o LUI (0x3700). sem essa transição, a instrução seguinte era pulada.
o addi usava aluop 01 no estado A0 (1a00), que virou 0a00 (aluop 00).
o estado 08 ficou com o LUI, então o branch foi para o estado 0A, com a saída 5201 (pcwritecond, alusrca = A, alusrcb = B, aluop 01 e pcsource = aluout). antes, o estado do branch não tinha nenhum sinal ligado.
mais importante: no JALR, o mux de dados do banco de registradores recebia o oldpc, que é o endereço do próprio jalr, e não PC + 4. a entrada foi religada no registrador PC, que depois da busca já vale PC + 4, e o regwrite passou para o estado 0B, junto com a escrita no PC, porque no estado 0C o PC já tem o destino do salto. o estado 0C deixou de ser usado.
o SLTIU recebeu a mesma correção do monociclo para não disparar no LUI, usando alusrca == 11 (que só acontece no estado 08 do LUI) como sinal de LUI.

= Correções Pipeline

adição das entradas de sw (024), tipo R (082) e branch (009) na ROM de controle, e o addi passou a usar aluop 00 (084).
o bit LUIsel estava ligado também no load e no addi (1d4 e 185), zerando o operando A dessas instruções. ele ficou ligado só no LUI (184).
o SLTIU recebeu a mesma correção do monociclo para não disparar no LUI, usando o sinal LUIsel que chega no estágio EX.
no JALR, a ROM de controle não tinha entrada para o opcode 0x67, então o JALR não fazia nada. foi adicionado o valor 284 (jalr_sel, regwrite e alusrc).
o fio do jalr_sel chegava na entrada de habilitação do mux antes do PC, e não no seletor. com o seletor solto e a habilitação em 0 nas outras instruções, o PC recebia um valor indefinido. o fio foi movido para o seletor.
mais importante: ao passar os fios do JALR, a linha do seletor do mux de desvio (branch AND zero) ganhou junções com a linha do ALUSrc e com o carry-in do somador de desvio, deixando os três sinais em curto. as junções foram desfeitas e as duas linhas voltaram a só se cruzar.
o registrador destino recebia o PC do próprio jalr, e não PC + 4. foi adicionado um somador PC + 4 no estágio EX, ligado ao mux por túneis (pc_ex e pc_mais_4_ex).
