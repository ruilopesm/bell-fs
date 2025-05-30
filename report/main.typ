#import "template.typ": *
#import "utils.typ": *

#show: project.with(
  title: [Tecnologias de Segurança],
  subtitle: [TP3 - Modelo Formal de Controlo de Acesso],
  authors: (
    (name: "Diogo Marques", affiliation: "PG55931"),
    (name: "Pedro Sousa", affiliation: "PG55994"),
    (name: "Rui Lopes", affiliation: "PG56009"),
  )
)

#outline(depth: 1)

= Introdução

Este relatório tem por objetivo apresentar o modelo de segurança desenvolvido no âmbito da unidade curricular de Tecnologias de Segurança, sendo o mesmo fortemente baseado no _Bell–LaPadula_ para garantir propriedades de confidencialidade, bem como outros modelos semelhantes para dotar o sistema dum maior dinamismo e consistência.

Enquanto implementação do modelo em questão, o grupo optou por desenvolver uma _Web API_ que disponibiliza todas as funcionalidades comuns a um sistema de ficheiros, sendo permitido criar compartimentos aos quais os utilizadores estão associados e daí escrever/ler ficheiros.

Por fim, numa tentativa de tornar a experiência de utilização mais rica, elaborámos uma interface minimalista que facilita a autenticação de utilizadores e a partir daí concede uma visão mais coesa de todo o sistema, mais concretamente os compartimentos e ficheiros acessíveis ao utilizador em questão. 

= Modelo de Controlo de Acesso

Dependendo do tipo de ambiente onde o sistema será aplicado, o modelo formal sustenta regras de controlo de acesso para um fim específico, que normalmente corresponde à obtenção de garantias como confidencialidade e segurança.

Embora o enunciado sugira somente o _Bell-LaPadula_ como fonte de inspiração, julgamos que tal não é suficiente à construção de um modelo genérico e aplicável em diversos ambientes. Nesse sentido, surgiu a necessidade de combinar vários modelos, respeitando, sempre, as propriedades de cada um.

Obviamente, o modelo de controlo de acesso perfeito não existe. No fundo, tudo se trata de _trade-offs_ entre confidencialidade, integridade e disponibilidade.

== Bell–LaPadula

Este modelo está especialmente voltado para garantir a confidencialidade do sistema, para isso o espaço de endereçamento é dividido em níveis de segurança hierárquicos sobre os quais os utilizadores operam e os ficheiros estão posicionados. Assim, as operações de escrita/leitura são efetuadas com base na compatibilidade entre níveis.

=== Propriedade Simples

Um utilizador não pode ler ficheiros cujo nível de confidencialidade seja superior ao seu. Deste modo, fugas de informação tornam-se impossíveis a partir de utilizadores com baixa patente de confidencialidade.

=== Propriedade Estrela

Um utilizador não pode escrever em níveis cuja confidencialidade seja inferior à sua. Por conseguinte, alguém _top-secret_ é incapacitado de escrever informação sensível onde não deve.

Isto é especialmente relevante para evitar fugas por descuido, visto que, à partida, um sujeito _top-secret_ é de confiança.

=== Funcionamento

Para melhor compreender o funcionamento deste modelo, apresenta-se um breve exemplo no qual recorremos aos dados apresentados nas seguintes tabelas. 

O utilizador _Rui_ é classificado como _secret_, como tal, é capaz de ler os ficheiros _main.py_, _text.txt_ e _object.jar_, visto terem associados uma confidencialidade mais relaxada.

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Utilizador*], [*Confidencialidade*],
        [Diogo], [#unclassified],
        [Pedro], [#classified],
        [Rui], [#secret],
        [Tiago], [#top-secret],
      )
    ),
    caption: [Confidencialidade dos utilizadores]
  ),
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Ficheiro*], [*Confidencialidade*],
        [main.py], [#unclassified],
        [text.txt], [#classified],
        [object.jar], [#secret],
        [file.c], [#top-secret],
      )
    ),
    caption: [Confidencialidade dos ficheiros]
  )
)

Por outro lado, o _Pedro_ é _classified_, daí  que não tenha escrito o ficheiro _main.py_. Posto isso, conseguimos concluir que esse ficheiro foi obrigatoriamente escrito por _Diogo_, dado ser o único utilizador com nível inferior ou igual a _unclassified_.

Embora a confidencialidade seja plenamente salvaguardada, o mesmo não acontece com a integridade, pois um utilizador de baixa patente (_Diogo_) tem capacidade para danificar ficheiros com elevado secretismo (_file.c_).

== Biba

Este modelo formal é basicamente o dual do _Bell–LaPadula_, daí que a propriedade de integridade seja preservada em detrimento da confidencialidade, assim sendo o espaço de endereçamento passa a ser dividido em níveis de integridade hierárquicos onde as escritas/leituras invertem de sentido.  

=== Propriedade Simples

Um utilizador não pode ler ficheiros cujo nível de integridade é inferior ao seu. Deste modo, será impossível induzir em erro qualquer sujeito, visto que esse sujeito apenas confia noutros que são tão ou mais íntegros que ele próprio.

=== Propriedade Estrela

Um utilizador não pode escrever em níveis cuja integridade é superior à sua. Quer isto dizer que alguém de baixa patente não é capaz de influenciar as decisões tomadas por alguém mais integro.

Numa breve analogia, o Presidente da República não confia em mim como informador (não sou da confiança dele), no entanto eu acredito nas declarações dele (o presidente tem a confiança dos cidadãos).

=== Funcionamento

Repetindo o exemplo anteriormente apresentado, o _Diogo_ pode ler os ficheiros _main.py_, _text.txt_ e _object.jar_, visto terem sido escritos por sujeitos de patente superior ou igual à sua. No entanto, o _Rui_ só tem acesso de leitura a _objet.jar_, e sendo ambos _strong_, foi obrigatoriamente o _Rui_ que escreveu esse ficheiro. No fundo, o _Diogo_ confia em todos os utilizadores, e o _Rui_ confia somente nele próprio.

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Utilizador*], [*Integridade*],
        [Diogo], [#weak],
        [Pedro], [#medium],
        [Rui], [#strong],
      )
    ),
    caption: [Integridade dos utilizadores]
  ),
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Ficheiro*], [*Integridade*],
        [main.py], [#weak],
        [text.txt], [#medium],
        [object.jar], [#strong],
      )
    ),
    caption: [Integridade dos ficheiros]
  )
)

== Muralha da China

Uma combinação dos modelos anteriores oferece propriedades de confidencialidade e integridade. No entanto, ambiente reais, nomeadamente o empresarial, requerem outros tipos de garantias. Se uma pessoa trabalha e tem acesso aos dados da empresa _X_, então jamais poderá conhecer informações associadas à firma concorrente _Y_.

Posto isto, e no sentido de enriquecer o modelo final, as classes de conflito traduzem a concorrência entre compartimentos. Mesmo que um utilizar possua níveis de integridade e confidencialidade compatíveis com o ficheiro, o acesso será negado caso exista um conflito entre compartimentos.

=== Funcionamento

Embora um utilizador possa estar associado a vários compartimentos, os ficheiros estão localizados apenas num. Posto isto, a verificação de conflitos é bastante facilitada, porque basta verificar a condição $#text("compartment.of.file") subset.eq #text("compartments.of.user")$.

#grid(
  columns: (1fr, 1fr),
  rows: (auto, auto),
  gutter: 10pt,
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Utilizador*], [*Compartimento*],
        [Diogo], [#braga],
        [Diogo], [#porto],
        [Rui], [#lisboa],
      )
    ),
    caption: [Compartimentos dos utilizadores]
  ),
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Ficheiro*], [*Compartimento*],
        [main.py], [#braga],
        [text.txt], [#porto],
        [object.jar], [#lisboa],
      )
    ),
    caption: [Compartimentos dos ficheiros]
  ),
  grid.cell(
    colspan: 2,
    figure(
      table(
        columns: (1fr, 1fr),
        inset: 5pt,
        align: horizon + left,
        fill: (x, y) =>
          if y == 0 { gray.lighten(60%) },
        table.header(
          [*Compartimento*], [*Compartimento conflituoso*],
          [#braga], [#lisboa],
          [#porto], [#lisboa],
        )
      ),
      caption: [Classes de conflito entre compartimentos]
    )
  )
)

Neste exemplo os compartimentos _Braga_ e _Porto_ são conflituosos com _Lisboa_, sendo por isso definidas duas classes de conflito, perante tal evidencia nenhum utilizador que esteja associado a _Braga_ ou _Porto_ poderá ter acesso ao ficheiro _object.jar_, visto que este pertence a _Lisboa_.

Como as classes de conflito são recíprocas, esta lógica é válida ao contrário, daí que _Rui_ não conheça os recursos _main.py_ e _text.txt_, tendo a sua visão limitada ao compartimento _Lisboa_ enquanto a ele estiver associado.

== Modelo Final

Uma combinação entre o _Bell–LaPadula_ e _Biba_ resulta numa formalização trivial do _Lipner_, no entanto julgamos que a resolução de conflitos é relevante em cenários mais realistas, daí que a nossa proposta de soluções seja uma combinação entre os três modelos previamente descritos.

Ao extrairmos os pontos fortes de cada modelo, conseguimos obter uma solução que assegura as propriedades de confidencialidade, integridade e respeito pelo concorrência.

=== Propriedades

Num cenário baseado em um modelo, ao verificarmos se um utilizador pode escrever/ler determinado recurso, costumamos verificar apenas uma condição, seja ela o nível de integridade ou confidencialidade. No entanto, a nossa proposta de solução requer três verificações por cada acesso, o que obviamente penaliza a performance.

- *Confidencialidade*
  + Não ler ficheiros cujo nível de confidencialidade é superior ao meu;
  + Não escrever em níveis cuja confidencialidade é inferior à minha.

- *Integridade*
  + Não ler ficheiros cujo nível de integridade é inferior ao meu;
  + Não escrever em níveis cuja integridade é superior à minha.

- *Resolução de Conflitos*
  + Não escrever/ler ficheiros cujo compartimento é conflituoso com algum dos meus.

No fundo, cada conjunto de regras pode ser traduzido numa _lattice_ parcialmente ordenada que descreve de forma mais sucinta e concreta o comportamento do modelo face a leituras e escritas.

- $l in L$: nível de confidencialidade
- $i in I$: nível de integridade
- $d subset.eq D$: conjunto dos compartimentos

Tendo isto em mente, os atributos $p_A eq (l_A​,i_A​,d_A​)$ pertencentes ao utilizador _A_ podem ser comparados com os do ficheiro _B_, $p_B eq (l_B​,i_B​,d_B​)$, a fim de autorizar o acesso solicitado pelas operações.

$ p_A lt.eq.slant p_B arrow.l.r.double.long l_A lt.eq.slant l_B and i_A gt.eq.slant i_B and d_B subset.eq d_A $

Com base nesta definição de ordenação, operações de leitura e escrita requerem a seguinte verificação:

$ A #text("pode ler") B arrow.l.r.double.long p_A gt.eq.slant p_B $

$ A #text("pode escrever sobre") B arrow.l.r.double.long p_A lt.eq.slant p_B $

Tal como nos dois primeiros modelos, a operação de leitura é o dual da escrita, e tendo em conta que o nosso modelo resulta, em parte, duma combinações entre esses dois, faz sentido que tal propriedade continue a verificar-se.

=== Funcionamento

Para melhor compreender o funcionamento do modelo, convém apresentar um caso prático onde todas as propriedades são aplicadas.

Neste exemplo, o _Diogo_ tem acesso aos compartimentos _Braga_ e _Porto_, tendo diferentes atributos associados em cada um. Nesse sentido, é-lhe permitida a leitura de _object.jar_, dado que a sua confidencialidade e integridade são respetivamente superior e inferior à do ficheiros.

Por outro lado, o _Diogo_ não é capaz de ler _text.txt_, porque o seu nível de confidencialidade não lhe confere acesso. No entanto, a escrita em _main.py_ e _text.txt_ é viabilizada pelo parâmetro de integridade.

#grid(
  columns: (1fr),
  rows: (auto, auto, auto),
  gutter: 10pt,
  figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Utilizador*], [*Confidencialidade*], [*Integridade*], [*Compartimento*],
        [Diogo], [#secret], [#strong], [#braga],
        [Diogo], [#classified], [#weak], [#porto],
        [Pedro], [#top-secret], [#medium], [#braga],
        [Rui], [#classified], [#weak], [#lisboa],
      )
    ),
    caption: [Atributos associados aos utilizadores]
  ),
  figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Ficheiro*], [*Confidencialidade*], [*Integridade*], [*Compartimento*],
        [main.py], [#top-secret], [#weak], [#braga],
        [text.txt], [#secret], [#weak], [#porto],
        [object.jar], [#unclassified], [#medium], [#porto],
        [file.c], [#classified], [#strong], [#lisboa],
      )
    ),
    caption: [Atributos associados aos ficheiros]
  ),
  figure(
      table(
        columns: (1fr, 1fr),
        inset: 5pt,
        align: horizon + left,
        fill: (x, y) =>
          if y == 0 { gray.lighten(60%) },
        table.header(
          [*Compartimento*], [*Compartimento conflituoso*],
          [#braga], [#lisboa],
          [#porto], [#lisboa],
        )
      ),
      caption: [Classes de conflito entre compartimentos]
    )
)

Por fim, o facto de _Braga_ e _Porto_ serem conflituosos com _Lisboa_ impede que o _Rui_ entre nesses compartimentos, ficando limitado à leitura de _file.c_. Em suma, a formulação matemática das permissões permite calcular computacionalmente os acessos concedidos a cada utilizador. 

#figure(
      table(
        columns: (1fr, 1fr, 1fr),
        inset: 5pt,
        align: horizon + left,
        fill: (x, y) =>
          if y == 0 { gray.lighten(60%) },
        table.header(
          [*Utilizador*], [*Acesso de Leitura*], [*Acesso de Escrita*],
          [Diogo], [object.jar], [main.py, text.txt],
          [Pedro], [object.jar], denied,
          [Rui], [file.c], denied
        )
      ),
      caption: [Acessos concedidos aos utilizadores]
)

= Melhorias ao Modelo

Apesar do modelo garantir diversas propriedades e ter um âmbito de aplicação diversificado, de pouco serve em cenários reais se não puder ser atualizado em tempo real. Assim sendo, a implementação desenvolvida permite modificar os atributos de confidencialidade e integridade associados a ficheiros, sendo essa operação de gestão dirigida exclusivamente por sujeitos confiáveis.

== Princípio da Tranquilidade

Uma vez que os atributos associados aos recursos são dinâmicos, basta garantir que a modificação dos mesmos não ocorre durante acessos de leitura/escrita de outros utilizadores, daí que o modelo assuma o *Princípio da Tranquilidade Fraca*.

Posto isto, os recursos do sistema são dotados de um ciclo de vida que corresponde às transições dos seus atributos, ou seja, o ficheiro _A_ permanece _top-secret_ durante alguns anos e depois é realizada uma expurgação que o torna _secret_, algo bastante comum em documentos de estado.

#block(
  width: 100%,
  inset: 8pt,
  radius: 5pt,
  stroke: black + 1pt,
  fill: luma(230),
  [
    2020-10-02 09:28:07 $arrow.r.long$ _top-secret_, _strong_
    
    2022-05-22 08:07:40 $arrow.r.long$ _classified_, _strong_

    2026-10-25 22:48:30 $arrow.r.long$ _unclassified_, _weak_
  ],
)

Neste exemplo de transição de estados, o ciclo de vida do ficheiro pode ser dividido em duas categorias. Uma respeitante à confidencialidade e outra à integridade. Deste modo, a gestão de atributos torna-se mais dinâmica e diminui ao máximo as dependências.

=== Sujeitos Confiáveis

Tal como referido anteriormente, somente utilizadores confiáveis são capazes de alterar os atributos de recursos, no entanto surge a dúvida de decidir quem é confiável ou não. Perante tal problema, o grupo optou por atribuir essa responsabilidade a uma entidade superior, neste caso um administrador de sistema.

Para além de identificar entidades confiáveis, o administrador também cria os compartimentos e procede à associação dos mesmos com os utilizadores. De realçar que um sujeito ser confiável num compartimento não implica que também o seja nos restantes.

=== Registo Dinâmico de Atributos

De modo a proceder à atribuição dos níveis de confidencialidade e integridade, primeiro é preciso conhecer a gama de valores disponível e a relação de ordem entre eles, ou seja, apesar de _top-secret_ ser evidentemente superior a _secret_, isso deve estar escrito duma forma mais genérica.

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Confidencialidade*], [*Nível*],
        [#unclassified], [1],
        [#classified], [2],
        [#secret], [3],
        [#top-secret], [4],
      )
    ),
    caption: [Níveis de confidencialidade]
  ),
  figure(
    table(
      columns: (1fr, 1fr),
      inset: 5pt,
      align: horizon + left,
      fill: (x, y) =>
        if y == 0 { gray.lighten(60%) },
      table.header(
        [*Integridade*], [*Nível*],
        [#weak],[1],
        [#medium], [2],
        [#strong], [3],
      )
    ),
    caption: [Níveis de integridade]
  ),
)

Quando um administrador regista um nível do confidencialidade, o mesmo atribui um nome que serve de identificador e um inteiro que o permite comparar com os demais parâmetros. Além disso, para inserir um nível entre _classified_ e _secret_ basta incrementar em uma unidade _secret_ e _top-secret_, a fim de deixar livre a terceira posição. 

Numa outra perspetiva, o registo de novos níveis não compromete a segurança do sistema, visto que a ordenação previamente vigente continua a ser respeitada, apenas foi adicionado algo novo que torna o sistema mais rico e dinâmico em termos de classificação dos atributos associados a recursos.

=== Regras de Gestão de Ficheiros

Ao serem disponibilizadas várias combinações entre atributos, torna-se complicado identificar a mais adequada a cada tipo de ficheiro. Dado isso, o grupo decidiu estabelecer um conjunto de regras sobre as ações que afetam diretamente o ciclo de vida.

==== Criação de Ficheiro

Quando um utilizador cria um ficheiro, por padrão, este herda a confidencialidade e integridade atribuídos ao utilizador no compartimento em questão. Precisamente por isso nenhuma das regras anteriormente definidas é violada, pois  o utilizador tem permissão de escrita e leitura sobre recursos do mesmo nível.

==== Eliminação de Ficheiro

A operação de eliminação é um caso particular da escrita. No entanto, é algo mais sensível, visto negar futuros acessos ao recurso. Assim, apenas sujeitos confiáveis são capazes de executar tal ação, respeitando a condição de terem confidencialidade e integridade superior ou igual à do próprio ficheiro.

$ p_A​ gt.tri.eq p_b arrow.l.r.double.long ​l_A​ gt.eq.slant l_B​ and i_A​ gt.eq.slant i_B​ and d_B​ subset.eq d_A​ $

Esta condição é significativamente diferente das apresentadas anteriormente, dado que os atributos não se aplicam da mesma forma, ou seja, apesar de alguém _top-secret_ não conseguir escrever em _secret_, a leitura é permitida e portanto existe autoridade para remover o ficheiro.

Numa outra análise, a integridade _weak_ não pode influenciar sujeitos _strong_, mas o contrário acontece, daí que a eliminação deva preservar essa relação. No fundo, a condição acima apresentada assegura que o utilizador _A_ é tão ou mais confiável/íntegro que o ficheiro _B_ em todos os aspetos. 

==== Reclassificação de Atributos

Para cumprir efetivamente com o princípio de tranquilidade fraca, os sujeitos confiáveis são capazes que reclassificar os atributos dos ficheiros, para isso seguem um conjunto de regras e visam salvaguardar as propriedades do modelo.

$ l_A gt.eq.slant l_"B old" and l_A gt.eq.slant l_"B new" $

$ i_A gt.eq.slant i_"B old" and i_A gt.eq.slant i_"B new" $

Para que o utilizador _A_ reclassifique a integridade de _B_, este deve possuir um nível superior ou igual. Além disso, a nova classificação do ficheiro não pode exceder o atributo do utilizador, caso contrário alguém pouco íntegro poderia induzir em erro os restantes participantes, violando assim a *Propriedade Estrela* do modelo _Biba_.

Seguindo a mesma lógica, a desclassificação de ficheiros ocorre quando o próprio utilizador já tem conhecimento acerca dos mesmos, portanto alguém de baixa patente estará impossibilitado de despromover ficheiros aos quais não tem acesso de leitura.

Este processo de reclassificação para níveis inferiores costuma ser acompanhado da expurgação de informação, no entanto, devido à falta de tempo, a implementação desenvolvida não disponibiliza essa funcionalidade, permitindo somente alterar a classificação sem modificar o conteúdo. 

===== Reclassificação Temporária

Ainda como medida adicional, o grupo pensou em implementar um mecanismo de reclassificação temporária para dotar o sistema duma maior flexibilidade e limitar os impactos provocados por uma desclassificação indevida.

Para tal, bastaria aos utilizadores de confiança indicar a nova classificação e o intervalo de tempo sobre o qual as alterações seriam efetivas, após esse limite o ciclo de vida seria automaticamente modificado, fazendo com que o ficheiro voltasse às permissões anteriores.

Seja como for, e novamente por questões de tempo, não tivemos a oportunidade de implementar tal funcionalidade, algo que definitivamente enriqueceria o sistema em termo de utilização. 

= Servidor

Para a devida concretização do modelo formalizado, o grupo optou pela implementação de uma _Web API_ como servidor de informação. Este servidor foi desenvolvido com recurso à linguagem _Elixir_ e à _framework web Phoenix_.

== Sistema de Dados

No entanto, antes da implementação propriamente dita, começamos por delinear o sistema de dados: tabelas, atributos e relacionamentos. Tal pode ser visto na @first_figure.

Pode-se dizer que a entidade central do sistema de dados será a tabela _UsersCompartments_, que define se existe uma relação entre um dado utilizador, ficheiro e compartimento, bem como o nível de integridade e confidencialidade associados.

Será contra esta tabela que serão verificadas a maioria das _queries_ ao sistema. Excetuando as que se tratam de conflitos entre compartimentos e, portanto, serão verificadas através da tabela _CompartmentConflicts_. Essencialmente, estamos perante uma matriz de autorização não esparsa.

#image_block(
  imagem: image("images/db.png"),
  caption: [Modelo lógico do sistema de dados]
) <first_figure>

== Endpoints

Esta secção pretende listar, exaustivamente, os _endpoints HTTP_ disponibilizados pelo servidor implementado.

=== Autenticação

- Registo: POST `/register`
- Login: POST `/login`
- Refrescar token: POST `/refresh`
- Logout: POST `/logout`

=== Utilizadores

- Ver o próprio utilizador: GET `/users/me`
- Pedir certificado de um dado utilizador: GET `/users/:username/certificate`

=== Ficheiros

- Listar os ficheiros a que um utilizador tem acesso: GET `/files`
- Adicionar ficheiro: POST `/files`
- Ler ficheiro: GET `/files/:id`
- Editar ficheiro (conteúdo): PUT `/files/:id`

=== Sujeitos Confiáveis

- Editar confidencialidade: PUT `/files/:id/confidentiality`
- Editar integridade: PUT `/files/:id/integrity`
- Eliminar ficheiro: DELETE `/files/:id`

=== Compartimentos

- Listar compartimentos a que temos acesso: GET `/compartments`

=== Administradores

- Criar compartimento: POST `/compartments`
- Criar conflito entre compartimentos: POST `/compartments/conflict`
- Adicionar utilizador a compartimento: PUT `/compartments/:id/:username`
- Remover utilizador de compartimento: DELETE `/compartments/:id/:username`
- Listar todos os níveis: GET `/levels`
- Criar nível: POST `/levels`

== Autorização

O servidor desenvolvido (em forma de _API_) utiliza um sistema de autorização baseado em _tokens JWT_, criadas e assinadas pelo próprio servidor. Estas _tokens_ existem, sempre, em pares: _access_ e _refresh_.

A _token_ de _access_ possui um tempo de vida de apenas 15 minutos, enquanto que a _token_ de _refresh_ possui um tempo de vida muito maior, de 30 dias. Este sistema híbrido permite que apenas a _token_ com menor tempo de vida seja frequentemente exposta, sendo que a _token_ de _refresh_ apenas é exposta para refrescar a _token_ de _access_ e é, imediatamente, revogada a seguir, dando lugar a um par completamente novo.

== Autenticação (2FA)

Com vista em aumentar a segurança do sistema de autenticação, para além do método tradicional baseado em _email_ e _password_, foi implementada também a autenticação por duplo fator (_2FA Authentication_).

É sabido que este tipo de autenticação mais tradicional (baseada em _email_ e _password_) possui diversas falhas de segurança inerentes à sua forma de funcionamento. Por exemplo, é comum que os utilizadores façam uso de _passwords_ com pouca segurança ou, até, que utilizem a mesma _password_ em diferentes serviços. Dada a existência de sujeitos confiáveis no nosso sistema torna-se, ainda mais, imperativa a implementação de uma autenticação baseada em _2FA_.

Quando um utilizador se regista, este recebe um _link_ para usar numa aplicação _TOTP_ (_Time Based One Time Password_), associando o segredo _TOTP_ (acordado com o servidor) no seu dispositivo pessoal. Este segredo irá permitir, posteriormente, a geração de um código aleatório para a realização de _login_.

Assim sendo, o servidor, para além de verificar as duas primeiras credenciais, verifica se o código _TOTP_ é válido, com base no segredo previamente acordado.

== Logs

Numa perspetiva de tornar o sistema auditável e associar os utilizadores às suas ações (assegurar a propriedade de não-repúdio), o grupo definiu um protocolo de comunicação no qual os pedidos realizados pelo cliente são acompanhados duma assinatura de `method + path + body`, algo que vai presente no campo `X-Signature` do _header_ _HTTP_.

Uma vez que o servidor possui o certificado do cliente, consequentemente também conhece a chave pública, nesse sentido a validade da assinatura pode ser confirmada, garantido portanto que o pedido foi efetivamente enviado pelo utilizador correto.

Por fim, caso a assinatura seja verificada com sucesso, o servidor devolve o conteúdo requisitado pelo cliente, sendo o _log_ e respetiva assinatura armazenados numa tabela da base de dados. Caso contrário, é devolvido um código de erro `401` que reencaminha o cliente de imediato para a página de _login_, ou, então, `400` quando o cliente nem sequer preenche o campo `X-Signature`.

De realçar que, em qualquer um dos casos, o _log_ de acesso ficou armazenado. E, portanto, tentativas de _Denial of Service_ ficam, também, registadas.

= Cliente
Como o objetivo de fornecer uma experiência de utilização agradável, o grupo optou por desenvolver uma _GUI_ baseada na ferramenta _Textual_, visto esta permitir o desenvolvimento rápido de interfaces gráficas com o mínimo de esforço. Além disso, acresce a possibilidade de executar o programa tanto na _terminal_ como num _browser_.

== GUI

A fim de concretizar a entrada e registo de utilizadores no sistema, foram elaborados dois menus para as respetivas funcionalidades. Na página de _login_ basta ao utilizador indicar o _email_ e _password_, enquanto na página de registo a lógica é semelhante, mas sendo necessário indicar o certificado.

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  image_block_small(
    imagem: image("images/login.png"),
    caption: [Página de _login_],
  ),
  image_block_small(
    imagem: image("images/register.png"),
    caption: [Página de registo],
  ),
)

Em seguida apresenta-se a página para visualização dos ficheiros contidos nos compartimentos associados ao utilizador, bem como um _modal_ para leitura e escrita dos próprio ficheiros. Além disso reparamos que na primeira página nem todos os botões são selecionáveis, algo que é definido pelas políticas de controlo de acesso apresentadas e discutidas anteriormente. 

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  image_block_small(
    imagem: image("images/files.png"),
    caption: [Página de visualização de ficheiros],
  ),
  image_block_small(
    imagem: image("images/file.png"),
    caption: [Página de edição de ficheiro],
  ),
)

Por fim, desenvolvemos uma página para suportar a adição de ficheiros, sendo que esta permite modificar à partida os atributos associados ao recurso, a fim de não herdar automaticamente as propriedades que o utilizador possui sobre o compartimento em questão.

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  image_block_small(
    imagem: image("images/add.png"),
    caption: [Página de criação de ficheiro],
  ),
  image_block_small(
    imagem: image("images/manage.png"),
    caption: [Página de gestão de atributos],
  ),
)

Por outro lado, ao clicar no botão _Manage_, o utilizador tem a possibilidade de reclassificar os ficheiros, algo permitido por um conjunto de _selectors_ que identificam os níveis para os quais é permitido mover os atributos do recurso. 

#pagebreak()

= Conclusão

Ao longo deste trabalho, o grupo desenvolveu e implementou um modelo formal de controlo de acesso que combina as propriedades do _Bell–LaPadula_, _Biba_ e Muralha da China, visando assegurar simultaneamente confidencialidade, integridade e gestão de conflitos de interesse entre compartimentos.

Ao integrar os três modelos, definiu-se uma estrutura matemática clara e rigorosa para a verificação de permissões de leitura/escrita, tendo por base os atributos dos utilizadores e dos ficheiros. Adicionalmente, foram introduzidas funcionalidades práticas como a reclassificação de atributos, gestão dinâmica de níveis e distinção entre utilizadores confiáveis e não confiáveis, elementos esses que reforçam a flexibilidade e segurança do sistema.

Do ponto de vista técnico, foi implementada uma _API_ que respeita as políticas de segurança delineadas, complementada por uma interface gráfica intuitiva que facilita a interação do utilizador com o sistema. Além disso, a utilização de _logs_ com assinatura digital garante o princípio de não-repúdio e permite auditar todas as ações realizadas.

Apesar das limitações de tempo que impediram a implementação de certas funcionalidades, o trabalho realizado oferece uma base sólida, extensível e aplicável a ambientes com necessidades diversas de controlo de acesso.
