# Testes finais — monociclo, multiciclo e pipeline

## Como executar

1. Abra o `.circ` e vá ao circuito principal (`main` ou `pipeline`). Confira se os pinos `manual`/`Debug` estão em 0.
2. Use **Simulate → Reset Simulation** (Ctrl+R). O reset também apaga as RAMs, então faça isso antes de carregar o programa.
3. Clique com o botão direito na memória de instruções e escolha **Load Image**. No monociclo é a ROM de instruções; no multiciclo é a RAM única; no pipeline é a RAM de instruções (a da esquerda).
   - Monociclo e multiciclo: use `tN_nome.txt`.
   - Pipeline: use `tN_nome_pipeline.txt`, que tem 3 NOPs depois de cada instrução, porque o pipeline não tem forwarding nem descarte de instruções.
4. Avance o clock com **Ctrl+T** (2 ticks = 1 ciclo). Todos os programas terminam em `fim: beq x0, x0, fim`, um laço infinito. Quando o PC parar nesse endereço, o programa acabou.
5. Clique com o botão direito no banco de registradores, escolha **View** e compare com a tabela de valores esperados.

Ciclos aproximados até o fim do programa: monociclo, 1 por instrução; multiciclo, 4 a 5 por instrução; pipeline, cerca de 4 por instrução da listagem (por causa dos NOPs) mais 4 no final.

## T1 — Aritmética básica e regressão do addi

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t1_aritmetica.txt`, `t1_aritmetica_pipeline.txt`

Confere addi (inclusive com imediato negativo), add, sub, and e or. Se o addi voltar a usar ALUop = 01, x1 aparece como 0xFFFFFFFB e x2 como 0xFFFFFC18. No multiciclo, add/sub/and/or passam pelos estados 0 → 1 → 6 → 7.

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `00500093` | `addi x1, x0, 5` |
| 4 | `3e800113` | `addi x2, x0, 1000` |
| 8 | `ff900193` | `addi x3, x0, -7` |
| 12 | `00208233` | `add  x4, x1, x2` |
| 16 | `402082b3` | `sub  x5, x1, x2` |
| 20 | `00c00313` | `addi x6, x0, 12` |
| 24 | `00a00393` | `addi x7, x0, 10` |
| 28 | `00737433` | `and  x8, x6, x7` |
| 32 | `007364b3` | `or   x9, x6, x7` |
| 36 | `00000063` | `beq x0, x0, fim` |

**Valores esperados:**

| Registrador | Valor |
|---|---|
| x1 | 0x00000005 (5) |
| x2 | 0x000003E8 (1000) |
| x3 | 0xFFFFFFF9 (-7) |
| x4 | 0x000003ED (1005) |
| x5 | 0xFFFFFC1D (-995) |
| x6 | 0x0000000C (12) |
| x7 | 0x0000000A (10) |
| x8 | 0x00000008 (8) |
| x9 | 0x0000000E (14) |

## T2 — Load e store

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t2_load_store.txt`, `t2_load_store_pipeline.txt`

No multiciclo, o sw passa por 0 → 1 → 2 → 5 e o lw por 0 → 1 → 2 → 3 → 4. No pipeline, este teste confere a entrada nova do sw (0x24) na ROM de controle: se ela faltar, x3 e x4 ficam em 0. O último lw usa x6 como base: se o operando A for zerado indevidamente (o bit LUIsel ligado no load, como estava na ROM do pipeline), x7 sai com o valor do endereço 4 em vez de −3.

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `00500093` | `addi x1, x0, 5` |
| 4 | `ffd00113` | `addi x2, x0, -3` |
| 8 | `10102023` | `sw   x1, 256(x0)` |
| 12 | `10202223` | `sw   x2, 260(x0)` |
| 16 | `10002183` | `lw   x3, 256(x0)` |
| 20 | `10402203` | `lw   x4, 260(x0)` |
| 24 | `004182b3` | `add  x5, x3, x4` |
| 28 | `10000313` | `addi x6, x0, 256` |
| 32 | `00432383` | `lw   x7, 4(x6)` |
| 36 | `00000063` | `beq x0, x0, fim` |

**Valores esperados:**

| Registrador | Valor |
|---|---|
| x1 | 0x00000005 (5) |
| x2 | 0xFFFFFFFD (-3) |
| x3 | 0x00000005 (5) |
| x4 | 0xFFFFFFFD (-3) |
| x5 | 0x00000002 (2) |
| x6 | 0x00000100 (256) |
| x7 | 0xFFFFFFFD (-3) |

## T3 — beq (desvio tomado e não tomado)

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t3_branch.txt`, `t3_branch_pipeline.txt`

x3 e x6 precisam continuar em 0: são instruções que o desvio deve pular. No multiciclo, o beq passa por 0 → 1 → 10 (0xA), e no estado 10 o sinal PCWriteCond tem que valer 1. No pipeline, a versão _pipeline tem 3 NOPs depois de cada beq, porque o pipeline não descarta as instruções que já entraram depois do desvio.

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `00500093` | `addi x1, x0, 5` |
| 4 | `00500113` | `addi x2, x0, 5` |
| 8 | `00208463` | `beq  x1, x2, pula` |
| 12 | `00100193` | `addi x3, x0, 1` |
| 16 | `00700213` | `addi x4, x0, 7` |
| 20 | `00008663` | `beq  x1, x0, errado` |
| 24 | `00900293` | `addi x5, x0, 9` |
| 28 | `00000463` | `beq  x0, x0, fim` |
| 32 | `00100313` | `addi x6, x0, 1` |
| 36 | `00000063` | `beq x0, x0, fim` |

**Valores esperados:**

| Registrador | Valor |
|---|---|
| x1 | 0x00000005 (5) |
| x2 | 0x00000005 (5) |
| x3 | 0x00000000 (0) |
| x4 | 0x00000007 (7) |
| x5 | 0x00000009 (9) |
| x6 | 0x00000000 (0) |

## T4 — div com sinal

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t4_div.txt`, `t4_div_pipeline.txt`

Cobre as combinações de sinal, o resultado truncado em direção a zero, a divisão por zero (resultado −1) e um sub logo depois, para confirmar que o div não afetou as outras operações da ALU.

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `ff900093` | `addi x1, x0, -7` |
| 4 | `00200113` | `addi x2, x0, 2` |
| 8 | `00000193` | `addi x3, x0, 0` |
| 12 | `00700513` | `addi x10, x0, 7` |
| 16 | `0220c233` | `div  x4, x1, x2` |
| 20 | `022542b3` | `div  x5, x10, x2` |
| 24 | `0210c333` | `div  x6, x1, x1` |
| 28 | `021143b3` | `div  x7, x2, x1` |
| 32 | `0230c433` | `div  x8, x1, x3` |
| 36 | `404284b3` | `sub  x9, x5, x4` |
| 40 | `00000063` | `beq x0, x0, fim` |

**Valores esperados:**

| Registrador | Valor |
|---|---|
| x1 | 0xFFFFFFF9 (-7) |
| x2 | 0x00000002 (2) |
| x3 | 0x00000000 (0) |
| x10 | 0x00000007 (7) |
| x4 | 0xFFFFFFFD (-3) |
| x5 | 0x00000003 (3) |
| x6 | 0x00000001 (1) |
| x7 | 0x00000000 (0) |
| x8 | 0xFFFFFFFF (-1) |
| x9 | 0x00000006 (6) |

## T5 — LUI

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t5_lui.txt`, `t5_lui_pipeline.txt`

O lui x3 tem o campo rs1 da instrução apontando para x1, que vale 5. Se o operando A da ALU não for zerado no LUI, x3 sai 0x00008005 em vez de 0x00008000. Os pares lui + addi conferem a montagem de constantes de 32 bits, inclusive com addi negativo. O lui x7 tem o campo funct3 igual a 011, o mesmo do sltiu: se a lógica do SLTIU não checar o LUI, x7 sai 0x00000001. O addi x8 logo depois do lui confere, no multiciclo, a transição da busca depois de um LUI; sem ela, a instrução seguinte é pulada e x8 fica em 0. No multiciclo, o lui passa pelos estados 0 → 1 → 8 → 9.

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `00500093` | `addi x1, x0, 5` |
| 4 | `12345137` | `lui  x2, 0x12345` |
| 8 | `000081b7` | `lui  x3, 0x00008` |
| 12 | `12345237` | `lui  x4, 0x12345` |
| 16 | `67820213` | `addi x4, x4, 0x678` |
| 20 | `fffff2b7` | `lui  x5, 0xFFFFF` |
| 24 | `12345337` | `lui  x6, 0x12345` |
| 28 | `fff30313` | `addi x6, x6, -1` |
| 32 | `000033b7` | `lui  x7, 0x00003` |
| 36 | `00138413` | `addi x8, x7, 1` |
| 40 | `00000063` | `beq x0, x0, fim` |

**Valores esperados:**

| Registrador | Valor |
|---|---|
| x1 | 0x00000005 (5) |
| x2 | 0x12345000 (305418240) |
| x3 | 0x00008000 (32768) |
| x4 | 0x12345678 (305419896) |
| x5 | 0xFFFFF000 (-4096) |
| x6 | 0x12344FFF (305418239) |
| x7 | 0x00003000 (12288) |
| x8 | 0x00003001 (12289) |

## T6 — SLTIU

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t6_sltiu.txt`, `t6_sltiu_pipeline.txt`

x6 e x7 são os casos que diferenciam a comparação sem sinal da comparação com sinal: um slti daria x6 = 1 e x7 = 0. x10 confere o caso de valores iguais, e x11 confere se um addi logo depois do sltiu ainda funciona.

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `00500093` | `addi  x1, x0, 5` |
| 4 | `fff00113` | `addi  x2, x0, -1` |
| 8 | `00a0b193` | `sltiu x3, x1, 10` |
| 12 | `0050b213` | `sltiu x4, x1, 5` |
| 16 | `0030b293` | `sltiu x5, x1, 3` |
| 20 | `00513313` | `sltiu x6, x2, 5` |
| 24 | `fff0b393` | `sltiu x7, x1, -1` |
| 28 | `00103413` | `sltiu x8, x0, 1` |
| 32 | `0010b493` | `sltiu x9, x1, 1` |
| 36 | `fff13513` | `sltiu x10, x2, -1` |
| 40 | `00108593` | `addi  x11, x1, 1` |
| 44 | `00000063` | `beq x0, x0, fim` |

**Valores esperados:**

| Registrador | Valor |
|---|---|
| x1 | 0x00000005 (5) |
| x2 | 0xFFFFFFFF (-1) |
| x3 | 0x00000001 (1) |
| x4 | 0x00000000 (0) |
| x5 | 0x00000000 (0) |
| x6 | 0x00000000 (0) |
| x7 | 0x00000001 (1) |
| x8 | 0x00000001 (1) |
| x9 | 0x00000000 (0) |
| x10 | 0x00000000 (0) |
| x11 | 0x00000006 (6) |

## T7 — JALR

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t7_jalr.txt`, `t7_jalr_pipeline.txt`

Confere o destino do salto (rs1 + imediato, com imediato zero e negativo) e o endereço de retorno, que tem que ser o PC + 4 da própria instrução jalr, e não a constante 4 nem o PC do jalr. x6, x7 e x10 precisam continuar em 0. Como os saltos acontecem em PCs diferentes de zero, o teste também detecta o PC recebendo um valor errado. No multiciclo, o jalr passa pelos estados 0 → 1 → 11 (0xB). No pipeline, o salto só acontece quando o jalr chega ao estágio EX; as 2 instruções que entraram depois dele são NOPs na versão _pipeline.

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `01400093` | `addi x1, x0, @alvo1` |
| 4 | `02800193` | `addi x3, x0, @alvo2+8` |
| 8 | `000082e7` | `jalr x5, 0(x1)` |
| 12 | `00100313` | `addi x6, x0, 1` |
| 16 | `00100393` | `addi x7, x0, 1` |
| 20 | `00700413` | `addi x8, x0, 7` |
| 24 | `ff8184e7` | `jalr x9, -8(x3)` |
| 28 | `00100513` | `addi x10, x0, 1` |
| 32 | `00500593` | `addi x11, x0, 5` |
| 36 | `00000063` | `beq x0, x0, fim` |

**Valores esperados (monociclo e multiciclo):**

| Registrador | Valor |
|---|---|
| x1 | 0x00000014 (20) |
| x3 | 0x00000028 (40) |
| x5 | 0x0000000C (12) |
| x6 | 0x00000000 (0) |
| x7 | 0x00000000 (0) |
| x8 | 0x00000007 (7) |
| x9 | 0x0000001C (28) |
| x10 | 0x00000000 (0) |
| x11 | 0x00000005 (5) |

**Valores esperados (pipeline, com os NOPs os endereços mudam):**

| Registrador | Valor |
|---|---|
| x1 | 0x00000050 (80) |
| x3 | 0x00000088 (136) |
| x5 | 0x00000024 (36) |
| x6 | 0x00000000 (0) |
| x7 | 0x00000000 (0) |
| x8 | 0x00000007 (7) |
| x9 | 0x00000064 (100) |
| x10 | 0x00000000 (0) |
| x11 | 0x00000005 (5) |

## T8 — BGE

**Máquinas:** monociclo, multiciclo e pipeline. **Arquivos:** `t8_bge.txt`, `t8_bge_pipeline.txt`

O primeiro bge compara 5 com −3: com sinal, 5 ≥ −3 e o desvio acontece; uma comparação sem sinal veria −3 como 0xFFFFFFFD e não desviaria, deixando x10 = 1. O segundo bge não pode desviar (x11 = 2), o terceiro confere o caso de igualdade, e os dois beq no fim confirmam que o beq continua funcionando depois da mudança. x10, x12 e x14 precisam continuar em 0. No multiciclo, o bge usa o mesmo estado do beq (0 → 1 → 10).

| Endereço | Código | Instrução |
|---|---|---|
| 0 | `00500093` | `addi x1, x0, 5` |
| 4 | `ffd00113` | `addi x2, x0, -3` |
| 8 | `00500193` | `addi x3, x0, 5` |
| 12 | `0020d463` | `bge  x1, x2, l1` |
| 16 | `00100513` | `addi x10, x0, 1` |
| 20 | `00115463` | `bge x2, x1, l2` |
| 24 | `00200593` | `addi x11, x0, 2` |
| 28 | `0030d463` | `bge x1, x3, l3` |
| 32 | `00100613` | `addi x12, x0, 1` |
| 36 | `00208463` | `beq x1, x2, l4` |
| 40 | `00300693` | `addi x13, x0, 3` |
| 44 | `00308463` | `beq x1, x3, l5` |
| 48 | `00100713` | `addi x14, x0, 1` |
| 52 | `00900793` | `addi x15, x0, 9` |
| 56 | `00000063` | `beq x0, x0, fim` |

**Valores esperados:**

| Registrador | Valor |
|---|---|
| x1 | 0x00000005 (5) |
| x2 | 0xFFFFFFFD (-3) |
| x3 | 0x00000005 (5) |
| x10 | 0x00000000 (0) |
| x11 | 0x00000002 (2) |
| x12 | 0x00000000 (0) |
| x13 | 0x00000003 (3) |
| x14 | 0x00000000 (0) |
| x15 | 0x00000009 (9) |

## Observações

- Os endereços 256 e 260 do T2 ficam longe do programa. Isso é importante no multiciclo, que usa uma memória só para instruções e dados.
- Se um teste falhar, anote em qual instrução o registrador saiu errado e tire um print do circuito nesse ciclo. No multiciclo, inclua também o valor do pino `Estado (debug)`.
