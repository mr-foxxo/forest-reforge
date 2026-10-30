# 01 · Roots — infraestrutura física

[English (default)](../../../modules/01-roots-physical.md) | [Português (Brasil)](01-roots-physical.md) | [Índice](../README.md)

**Estado:** famílias de hardware e topologia relatadas pelas fontes; montagem do rack proposta. Não foram fornecidos dimensões, lista de cortes, capacidade dos disjuntores ou cargas medidas.

## Preparação e montagem

1. Inventarie dimensão/massa dos chassis, trilhos compatíveis, profundidade útil, capacidade de prateleiras/piso, acesso frontal/traseiro, direção do ar e desligamento de emergência. Largura de 19 polegadas não define profundidade ou carga.
2. Para estrutura própria, documente materiais, juntas, contraventamento, ancoragem e aterramento com assistência competente. Use trilhos e suportes dimensionados.
3. Nivele e fixe o rack; coloque UPS e equipamentos pesados na parte inferior. Preserve acesso a BMC e fontes; use ajuda adequada para erguer servidores.
4. Evite recirculação de ar com organização de entradas/saídas e painéis cegos quando necessários.
5. Identifique as duas pontas de cada cabo antes de agrupar. Registre `origem-porta → destino-porta / zona`.
6. Verifique terra de proteção, circuito, PDU e UPS conforme equipamentos e regras locais, com profissional qualificado. Não improvise rede elétrica.
7. Ligue um sistema por vez; meça boot, repouso e carga representativa, temperaturas e desligamento controlado.

## Energia e refrigeração

Capacidade nominal de fonte não é consumo medido. Duas fontes de 870 W não implicam consumo constante de 1740 W. Verifique W, VA, fator de potência, pico de partida, envelhecimento da bateria e capacidade de cada alimentação remanescente. Duas entradas na mesma PDU compartilham falha.

Para planejamento: kWh mensais = potência média na tomada em W × horas / 1000. Compare aquisição, energia, refrigeração, manutenção e licenças com equipamento substituto.

Tesla passiva exige fluxo de ar dirigido. Confirme duto, dissipador, falha de ventilação e temperatura com carga real; não deixe stress sem supervisão antes da qualificação. Consulte pinagem exata: EPS/CPU e GPU visualmente parecidos podem ser incompatíveis. P4 sem alimentação auxiliar ainda exige capacidade do slot/riser.

Separe switches por confiança, sem unir zonas acidentalmente. Registre ópticas, velocidades e failover WAN sem presumir validação por haver dois uplinks. Preencha o [registro físico](../examples/physical-build-record.md). Em sobrecarga, calor ou instabilidade, interrompa e retorne à configuração segura.
