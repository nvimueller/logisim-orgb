#set page(paper:"a4",margin:2cm)
#set text(font:"New Computer Modern", size:11pt, lang:"pt")
#set par(justify: true)

#align(center)[
  *UNIVERSIDADE FEDERAL DO RIO GRANDE DO SUL*\
  *INSTITUTO DE INFORMÁTICA*\
  *ORGANIZAÇÃO DE COMPUTADORES*
]

#v(0.2fr)

#align(center)[
  ERICK FRANCO\
  GUSTAVO CAMILOTTI\
  LUCAS VIEIRA\
  LUIZ SCHARDOSIM\
  ISMAEL MÜLLER
]

#v(0.3fr)

#align(center)[*IMPLEMENTAÇÃO DE INSTRUÇÕES NO RISC-V*]

#v(1fr)

#align(center)[PORTO ALEGRE\ 2026]

#pagebreak()

#set page(paper:"a4",margin:2cm, columns:2)
#text(size:12pt)[*INTRODUÇÃO*]

Este trabalho tem como objetivo relatar o processo de implementação das instruções `JALR`, `BGE`, `LUI`, `DIV` e `SLTIU` na arquitetura de um processador RISC-V. A distribuição dessas instruções entre os alunos participantes foi realizada por meio de sorteio prévio. Ademais, para facilitar o acompanhamento, é importante ressaltar que a ordem de implementação das instruções foi, respectivamente, `SLTIU`, `LUI`, `DIV`, `JALR` e `BGE`.


#text(size:12pt)[*MONOCICLO*]

#text(size:12pt)[*`SLTIU`*]

A subtração utilizada pela instrução foi configurada manualmente pelos sinais de controle `aluop`, sem a necessidade de fazer uso do campo func3 da instrução para determinar a operação realizada pela ULA. Quanto à flag que comunica a magnitude do registrador frente ao valor imediato, basta utilizar o campo de `bout` do subtrator
da própria `ULA`. Contudo, ao produzir um novo output na ULA, temos que possibilitar a saída do mesmo para ser, agora, escrito no banco de registradores, a saber, no registrador `rd`, informado pela instrução. Isso pode ser resolvido simplesmente adicionando um `mux` à saída de `aluout`, cujo sinal de controle será uma `AND` que corresponde aos bits do campo func3 da instrução. Essa solução, a princípio, pode ser aplicada pois o campo func3 da instrução corresponde a `011`, sendo uma das duas únicas instruções que possuem esse valor.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [regwrite], [alusrc], [memwrite], [aluop1], [aluop0], [memtoreg], [memread], [branch]),
      [0], [1], [1], [0], [0], [0], [0], [0], [0]
    )
  )
]

#v(8pt)

#text(size:12pt)[*`LUI`*]

De modo a possibilitar o `load` de uma constante de vinte _bits_ para um registrador e preenchê-la com zeros à direita, foi necessário ajustar o gerador de imediatos de acordo com o código da operação da instrução `type-R`. Uma outra mudança crucial, porém, foi a adição de um `mux` capaz de controlar a entrada da `ULA`, o qual seleciona ou o registrador `rs1` ou uma constante zero, que, neste caso deverá ser somada com o _output_ do gerador de imediato. Ademais, apesar de `LUI` não possuir o campo `func3`, os três últimos bits do imediato podem coincidir com o `func3` de `SLTIU`, o que, por sua vez, pode gerar um conflito com a configuração do `mux` que escolhe entre a operação da `ULA` e a _flag_ de `bout` do subtrator. Desse modo, foi necessário adicionar outro `mux`, o qual só permite que `bout` passe se e somente se a instrução não seja `LUI`.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [regwrite], [alusrc], [memwrite], [aluop1], [aluop0], [memtoreg], [memread], [branch]),
      [0], [1], [1], [0], [0], [0], [0], [0], [0]
    )
  )
]

#v(8pt)
#text(size:12pt)[*`DIV`*]

Aqui foi realizada a adição de um divisor com sinal na `ULA`, ligado na terceira entrada do `mux` de operações, que estava livre. Como o divisor da ferramenta só efetua divisão sem sinal, o circuito divide os módulos dos operandos e nega o quociente quando os sinais de A e B são diferente. Além disso, quanto ao tratamento de casos especiais, a divisão por zero retorna −1 (`0xFFFFFFFF`). A `ROM` de controle, por sua vez, não precisou de mudança porque DIV usa o mesmo `opcode` do `R-type`.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [regwrite], [alusrc], [memwrite], [aluop1], [aluop0], [memtoreg], [memread], [branch]),
      [0], [1], [0], [0], [1], [0], [0], [0], [0]
    )
  )
]

#v(8pt)
#text(size:12pt)[*`JALR`*]

Foi colocado um novo `mux` logo antes do PC para ele poder receber o endereço do salto direto da `ULA` (`rs1+imm`). Ademais, foi colocado outro `mux` na entrada de dados do banco de registradores pra conseguirmos salvar o `PC+4` no registrador destino. No bloco de controle, foi criada uma flag nova chamada `jalrsel` que aciona esses dois multiplexadores ao mesmo tempo. De modo a fazer isso caber, foi necessário aumentar os _splitters_ e a `ROM` de controle para nove _bits_.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [regwrite], [alusrc], [memwrite], [aluop1], [aluop0], [memtoreg], [memread], [branch]),
      [1], [1], [1], [0], [0], [0], [0], [0], [0]
    )
  )
]

#v(8pt)
#text(size:12pt)[*`BGE`*]

Aqui, usa-se o mesmo `opcode` e o mesmo imediato do `BEQ`, logo a `ROM` de controle e o gerador de imediatos não mudaram. Ademais, foi necessário adicionar um comparador com sinal entre `rs1` e `rs2`, pois a flag `menor que` da `ULA` compara sem sinal, além de um `mux` antes da porta `AND` do desvio, controlado pelo `funct3`. Assim, se for igual a `101`, a porta `AND` recebe `rs1>=rs2`, senão, recebe o zero normal da `ULA`.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [regwrite], [alusrc], [memwrite], [aluop1], [aluop0], [memtoreg], [memread], [branch]),
      [0], [0], [0], [0], [0], [1], [0], [0], [1]
    )
  )
]

#v(8pt)

#pagebreak()

#text(size:12pt)[*MULTICICLO*]

#text(size:12pt)[*`SLTIU`*]

Além das modificações na memória, o `mux` responsável pela seleção do valor que sai da `ULA` teve de ser modificado, adicionando a ele uma nova entrada, além das outras três correspondentes ao campo `func3` da instrução. Foi-se usado um comparador para checar se o estado era maior que zero, pois ao final da instrução, no ciclo de busca da próxima, a `ULA` necessita ser utilizada para o incremento do `PC`, algo que era prejudicado pelo permanecimento dos sinais do campo `func3` ativos, o que selecionava a _flag_ do subtrator da `ULA` ao invés do resultado do incremento do `PC`.

#text(size:8pt)[
  #figure(
    table(
      columns:12,
      align:center,
      stroke:0.5pt,
      table.header([pcsrc], [aluop], [alusrcb], [alusrca], [regwrite], [irwrite], [memtoreg], [memwrite], [memread], [iord], [pcwrite], [pcwritecond]),
      [0], [00], [01], [00], [0], [1], [0], [0], [1], [0], [1], [0],
      [0], [00], [11], [01], [0], [0], [0], [0], [0], [0], [0], [0],
      [0], [00], [10], [10], [0], [0], [0], [0], [0], [0], [0], [0],
      [0], [00], [00], [00], [1], [0], [0], [0], [0], [0], [0], [0],
    )
  )
]

#v(8pt)

#text(size:12pt)[*`LUI`*]

Além da mesma mudança na extensão do gerador de imediato que foi executada na configuração monociclo, o `mux` responsável por selecionar o recebimento da `ULA` foi aproveitado da própria organização do modelo do processador, possibilitando a simples inclusão da constante zero necessária para a soma com o valor imediato à uma das suas entradas. Além disso, também foi necessário introduzir uma mudança que permita a passagem de `bout` se e somente se a instrução corrente não é `LUI`.

#text(size:8pt)[
  #figure(
    table(
      columns:12,
      align:center,
      stroke:0.5pt,
      table.header([pcsrc], [aluop], [alusrcb], [alusrca], [regwrite], [irwrite], [memtoreg], [memwrite], [memread], [iord], [pcwrite], [pcwritecond]),
      [0], [00], [01], [00], [0], [1], [0], [0], [1], [0], [1], [0],
      [0], [00], [11], [01], [0], [0], [0], [0], [0], [0], [0], [0],
      [0], [00], [10], [11], [0], [0], [0], [0], [0], [0], [0], [0],
      [0], [00], [00], [00], [1], [0], [0], [0], [0], [0], [0], [0],
    )
  )
]

#v(8pt)

#text(size:12pt)[*`DIV`*]

Quanto às mudanças aqui necessárias, foram iguais às do monociclo na ULA e no controle da ULA, pois os blocos são os mesmos. Quanto á ROM, foi programada a ROM para suportar a instrução de acordo o `type-R`, que estava faltando.

#text(size:8pt)[
  #figure(
    table(
      columns:12,
      align:center,
      stroke:0.5pt,
      table.header([pcsrc], [aluop], [alusrcb], [alusrca], [regwrite], [irwrite], [memtoreg], [memwrite], [memread], [iord], [pcwrite], [pcwritecond]),
      [0], [00], [01], [00], [0], [1], [0], [0], [1], [0], [1], [0],
      [0], [00], [11], [01], [0], [0], [0], [0], [0], [0], [0], [0],
      [0], [10], [00], [10], [0], [0], [0], [0], [0], [0], [0], [0],
      [0], [00], [00], [00], [1], [0], [0], [0], [0], [0], [0], [0],
    )
  )
]

#v(8pt)

#text(size:12pt)[*`JALR`*]

Aqui, o bloco operativo foi modificado com a adição de um segundo `mux` logo antes da entrada de dados do banco de registradores para encaminhar o endereço de retorno (`oldpc`). A seleção desse `mux` é feita de forma combinacional por um comparador focado exclusivamente no `opcode` do `JALR`, garantindo que as instruções originais continuem a funcionar normalmente.

#text(size:8pt)[
  #figure(
    table(
      columns:12,
      align:center,
      stroke:0.5pt,
      table.header([pcsrc], [aluop], [alusrcb], [alusrca], [regwrite], [irwrite], [memtoreg], [memwrite], [memread], [iord], [pcwrite], [pcwritecond]),
      [0], [00], [01], [00], [0], [1], [0], [0], [1], [0], [1], [0],
      [0], [00], [11], [01], [0], [0], [0], [0], [0], [0], [0], [0],
      [0], [00], [10], [10], [1], [0], [0], [0], [0], [0], [1], [0]
    )
  )
]

#v(8pt)

#text(size:12pt)[*`BGE`*]

Para o `BGE`, foi implementada a mesma lógica do monociclo, obtendo A e B na saída dos multiplexadores `alusrca` e `alusrcb`. Por sua vez, as `ROMs` não mudaram, pois o `BGE` passa pelos mesmos estados do `BEQ`.

#text(size:8pt)[
  #figure(
    table(
      columns:12,
      align:center,
      stroke:0.5pt,
      table.header([pcsrc], [aluop], [alusrcb], [alusrca], [regwrite], [irwrite], [memtoreg], [memwrite], [memread], [iord], [pcwrite], [pcwritecond]),
      [0], [00], [01], [00], [0], [1], [0], [0], [1], [0], [1], [0],
      [0], [00], [11], [01], [0], [0], [0], [0], [0], [0], [0], [0],
      [1], [01], [00], [10], [0], [0], [0], [0], [0], [0], [0], [1],
    )
  )
]

#pagebreak()

#text(size:11pt)[*DIAGRAMA DE ESTADOS*]

#image("diagram.png", height:90%, fit:"contain")

#pagebreak()

#text(size:12pt)[*PIPELINE*]

#text(size:12pt)[*`SLTIU`*]

Aqui, a mudança na saída da `ULA` de modo a suportar a escrita no `rd` também foi feita por meio de um `mux` ativado pelos campos de `func3`. Dessa vez, porém, o `func3` utilizado para selecionar o valor a ser escrito no registrador é obtido do registrador que salva exatamente o campo `func3`, e não diretamente de `RI`.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [luisel], [regwrite], [memtoreg], [memwrite], [memread], [branch], [alusrc], [aluop]),
      [0], [0], [1], [0], [0], [0], [0], [1], [00]
  )
)
]

#v(8pt)

#text(size:12pt)[*`LUI`*]

Na implementação de `LUI` no processador _pipeline_, por sua vez, foi necessário a expansão da memória em um _bit_ de modo a introduzir uma nova _flag_ chamada `luisel`, utilizada tanto para a seleção da constante zero que deve ser recebida pela `ULA` quanto para o funcionamento correto de `SLTIU` pela razão já enunciada anteriormente. Adicionalmente, foi realizado um roteamento minucioso dos fios no separador da barreira `ID/EX` para respeitar o fluxo do pipeline. Os sinais de execução `aluop` e `alusrc` foram isolados para dissiparem-se no estágio `EX`, e o novo sinal `luisel` fui puxado para comandar a entrada da `ULA` no mesmo estágio, e os sinais de `MEM` e `WB` foram agrupados em um novo separador para continuarem a viagem até ao registrador `EX/MEM`.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [luisel], [regwrite], [memtoreg], [memwrite], [memread], [branch], [alusrc], [aluop]),
      [0], [1], [1], [0], [0], [0], [0], [1], [00]
    )
  )
]

#v(8pt)

#text(size:12pt)[*`DIV`*]

Novamente aqui, as mudanças são idênticas àquelas feitas para o funcionamento da instrução no monociclo, assim como o controle da `ULA`.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [luisel], [regwrite], [memtoreg], [memwrite], [memread], [branch], [alusrc], [aluop]),
      [0], [0], [1], [0], [0], [0], [0], [0], [10]
    )
  )
]

#v(8pt)

#text(size:12pt)[*`JALR`*]

Para `JALR`, houve a expansão do barramento da unidade de controle,
além de um novo `mux` antes do `PC`, que recebe o resultado da ULA (`rs1 + imm`) quando `jalrsel` está ligado. Ademais, houve a adição de um `mux` no estágio `EX`, que troca o resultado da `ULA` por `PC+4` antes de ir para a barreira `EX/MEM`, para salvar o endereço de retorno em `rd`. Como o PC que chega em `EX` é o da própria instrução, foi adicionado um somador `PC+4` nesse estágio. O salto acontece no estágio `EX` e as duas instruções que entraram depois de `JALR` também executam, logo é preciso inserir `NOPs` logo após a instrução.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [luisel], [regwrite], [memtoreg], [memwrite], [memread], [branch], [alusrc], [aluop]),
      [1], [0], [1], [0], [0], [0], [0], [1], [00]
    )
  )
]

#v(8pt)

#text(size:12pt)[*`BGE`*]

Aqui, a lógica foi transferida para dentro da `ULA` e do controle da `ULA`, pois o estágio `EX` já estava tomado de fios. O controle da `ULA` manda o código sete quando é desvio com `funct3=101`, senão, manda seis (`BEQ`). Na `ULA`, o código sete faz a subtração normal, mas a saída zero passa a ser o resultado de `A>=B` com sinal. Assim o resto do desvio no pipeline continua igual.

#text(size:10pt)[
  #figure(
    table(
      columns:9,
      align:center,
      stroke:0.5pt,
      table.header([jalrsel], [luisel], [regwrite], [memtoreg], [memwrite], [memread], [branch], [alusrc], [aluop]),
      [0], [0], [0], [0], [0], [0], [1], [0], [01]
    )
  )
]

#v(8pt)

#pagebreak()

#text(size:12pt)[*TESTES*]

#text(size:11pt)[*`DIV`*]

#align(center)[
  #table(
    columns: 3,
    [Endereço], [Código], [Instrução],
    [0], [FF900093], [addi x1, x0, -7],
    [4], [00200113], [addi x2, x0, 2],
    [8], [00000193], [addi x3, x0, 0],
    [12], [00700513], [addi x10, x0, 7],
    [16], [0220c233], [div x4, x1, x2],
    [20], [022542b3], [div x5, x10, x2],
    [24], [0210c333], [div x6, x1, x1],
    [28], [021143b3], [div x7, x2, x1],
    [32], [0230c433], [div x8, x1, x3],
    [36], [404284b3], [sub x9, x5, x4],
    [40], [00000063], [beq x0, x0, fim]
  )
]

Valores esperados:

#align(center)[
  #table(
    columns: 2,
    [Registrador], [Valor],
    [x1], [0xFFFFFFF9 (-7)],
    [x2], [0x00000002 (2)],
    [x3], [0x00000000 (0)],
    [x10], [0x00000007 (7)],
    [x4], [0xFFFFFFFD (-3)],
    [x5], [0x00000003 (3)],
    [x6], [0x00000001 (1)],
    [x7], [0x00000000 (0)],
    [x8], [0xFFFFFFFF (-1)],
    [x9], [0x00000006 (6)]
  )
]

#text(size:11pt)[*`LUI`*]

#align(center)[
  #table(
    columns: 3,
    [Endereço], [Código], [Instrução],
    [0], [00500093], [addi x1, x0, 5],
    [4], [12345137], [lui x2, 0x12345],
    [8], [000081b7], [lui x3, 0x00008],
    [12], [12345237], [lui x4, 0x12345],
    [16], [67820213], [addi x4, x4, 0x678],
    [20], [fffff2b7], [lui x5, 0xFFFFF],
    [24], [12345337], [lui x6, 0x12345],
    [28], [fff30313], [addi x6, x6, -1],
    [32], [000033b7], [lui x7, 0x00003],
    [36], [00138413], [addi x8, x7, 1],
    [40], [00000063], [beq x0, x0, fim]
  )
]

Valores esperados:

#align(center)[
  #table(
    columns: 2,
    [Registrador], [Valor],
    [x1], [0x00000005 (5)],
    [x2], [0x12345000 (305418240)],
    [x3], [0x00008000 (32768)],
    [x4], [0x12345678 (305419896)],
    [x5], [0xFFFFF000 (-4096)],
    [x6], [0x12344FFF (305418239)],
    [x7], [0x00003000 (12288)],
    [x8], [0x00003001 (12289)]
  )
]

#text(size:11pt)[*`SLTIU`*]

#align(center)[
  #table(
    columns: 3,
    [Endereço], [Código], [Instrução],
    [0], [00500093], [addi x1, x0, 5],
    [4], [fff00113], [addi x2, x0, -1],
    [8], [00a0b193], [sltiu x3, x1, 10],
    [12], [0050b213], [sltiu x4, x1, 5],
    [16], [0030b293], [sltiu x5, x1, 3],
    [20], [00513313], [sltiu x6, x2, 5],
    [24], [fff0b393], [sltiu x7, x1, -1],
    [28], [00103413], [sltiu x8, x0, 1],
    [32], [0010b493], [sltiu x9, x1, 1],
    [36], [fff13513], [sltiu x10, x2, -1],
    [40], [00108593], [addi x11, x1, 1],
    [44], [00000063], [beq x0, x0, fim]
  )
]

Valores esperados:

#align(center)[
  #table(
    columns: 2,
    [Registrador], [Valor],
    [x1], [0x00000005 (5)],
    [x2], [0xFFFFFFFF (-1)],
    [x3], [0x00000001 (1)],
    [x4], [0x00000000 (0)],
    [x5], [0x00000000 (0)],
    [x6], [0x00000000 (0)],
    [x7], [0x00000001 (1)],
    [x8], [0x00000001 (1)],
    [x9], [0x00000000 (0)],
    [x10], [0x00000000 (0)],
    [x11], [0x00000006 (6)]
  )
]

#pagebreak()

#text(size:11pt)[*`JALR`*]

#align(center)[
  #table(
    columns: 3,
    [Endereço], [Código], [Instrução],
    [0], [01400093], [addi x1, x0, \@alvo1],
    [4], [02800193], [addi x3, x0, \@alvo2+8],
    [8], [000082e7], [jalr x5, 0(x1)],
    [12], [00100313], [addi x6, x0, 1],
    [16], [00100393], [addi x7, x0, 1],
    [20], [00700413], [addi x8, x0, 7],
    [24], [ff8184e7], [jalr x9, -8(x3)],
    [28], [00100513], [addi x10, x0, 1],
    [32], [00500593], [addi x11, x0, 5],
    [36], [00000063], [beq x0, x0, fim]
  )
]

Valores esperados (monociclo e multiciclo):

#align(center)[
  #table(
    columns: 2,
    [Registrador], [Valor],
    [x1], [0x00000014 (20)],
    [x3], [0x00000028 (40)],
    [x5], [0x0000000C (12)],
    [x6], [0x00000000 (0)],
    [x7], [0x00000000 (0)],
    [x8], [0x00000007 (7)],
    [x9], [0x0000001C (28)],
    [x10], [0x00000000 (0)],
    [x11], [0x00000005 (5)]
  )
]

Valores esperados:

#align(center)[
  #table(
    columns: 2,
    [Registrador], [Valor],
    [x1], [0x00000050 (80)],
    [x3], [0x00000088 (136)],
    [x5], [0x00000024 (36)],
    [x6], [0x00000000 (0)],
    [x7], [0x00000000 (0)],
    [x8], [0x00000007 (7)],
    [x9], [0x00000064 (100)],
    [x10], [0x00000000 (0)],
    [x11], [0x00000005 (5)]
  )
]

#text(size:11pt)[*`BGE`*]

#align(center)[
  #table(
    columns: 3,
    [Endereço], [Código], [Instrução],
    [0], [00500093], [addi x1, x0, 5],
    [4], [ffd00113], [addi x2, x0, -3],
    [8], [00500193], [addi x3, x0, 5],
    [12], [0020d463], [bge x1, x2, l1],
    [16], [00100513], [addi x10, x0, 1],
    [20], [00115463], [bge x2, x1, l2],
    [24], [00200593], [addi x11, x0, 2],
    [28], [0030d463], [bge x1, x3, l3],
    [32], [00100613], [addi x12, x0, 1],
    [36], [00208463], [beq x1, x2, l4],
    [40], [00300693], [addi x13, x0, 3],
    [44], [00308463], [beq x1, x3, l5],
    [48], [00100713], [addi x14, x0, 1],
    [52], [00900793], [addi x15, x0, 9],
    [56], [00000063], [beq x0, x0, fim]
  )
]

Valores esperados:

#align(center)[
  #table(
    columns: 2,
    [Registrador], [Valor],
    [x1], [0x00000005 (5)],
    [x2], [0xFFFFFFFD (-3)],
    [x3], [0x00000005 (5)],
    [x10], [0x00000000 (0)],
    [x11], [0x00000002 (2)],
    [x12], [0x00000000 (0)],
    [x13], [0x00000003 (3)],
    [x14], [0x00000000 (0)],
    [x15], [0x00000009 (9)]
  )
]
