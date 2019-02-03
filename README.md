**Nota:** aparentemente, o Bitbucket não é capaz de renderizar este arquivo corretamente. Recomenda-se usar [StackEdit](https://stackedit.io/app).

# Teste eSapiens - Algoritmo
Aplicação CLI relativa ao teste para a vaga dev Android/backend na empresa eSapiens.

A aplicação determina se um conjunto de caixas com pesos diversões pode ser transportado de um suposto piso para outro, usando o mecanismo de polia descrito no enunciado do teste. 


## Características
 - Plataforma: macOS 10.13+;
 - Linguagem: Swift 4;
 - Suporte a parâmetros pela CLI;
 - Nenhuma dependência;
 - Nenhum erro ou alerta de compilação..

O mecanismo de polia apresentado para o teste funciona por meio de dois elevadores conectados através de uma corda que passa por uma polia; quando um deles sobe, o outro desce. Contudo, o mecanismo apresenta uma limitação: a diferença de peso entre os conteúdos de cada elevador nunca pode exceder um determinado peso (postulado no enunciado como **8**, embora, aqui, parametrizável). 

Em síntese, tal verificação pode consistir somente em ordenar as caixas por peso e verificar se a diferença de peso entre duas delas consecutivas não excede o máximo especificado. A razão para isso é que, uma vez confirmado esse detalhe, **sempre** será possível transportá-las todas sem quebrar o mecanismo.

A realocação, então, é feita transportando as caixas, da mais leve para a mais pesada, para lá e de volta; enquanto uma pesada vai, a anterior, mais leve, volta, exceto pela caixa mais pesada, que não é retornada. A partir daí, o processo é reiniciado, mas agora com uma caixa a menos no piso de cá. O ciclo, obviamente, encerra quando todas as caixas terminarem de ser transportadas. 

## Uso 

*Per* enunciado do teste, a aplicação necessita de, pelo menos, dois argumentos:
- Quantidade de caixas a serem transportadas, como um integer não-negativo (e.g., `3`)
- Peso de cada caixa, como integers positivos (e.g., `4 10 15`) ou string de integers positivos separados por espaço (e.g., `"4 10 15"`)

Adicionalmente, também é possível fornecer dois arguments adicionais ao final do comando (nessa ordem):
- `--weight=<integer_positivo>`: determina a diferença de peso máxima suportada pelo mecanismo
- `--debug`: apresenta mensagens de log e executa casos de teste.

O retorno padrão da aplicação é uma única letra: `S` caso o transporte seja possível, `N`do contrário.

### Exemplos
#### Fornecendo pesos inline
```bash
$ ./eSapiensAlg 3 4 10 15

$ ./eSapiensAlg 4 "5 1 5 15"
```
![pesos inline](https://i.imgur.com/GEUWIL0.png)

#### Fornecendo pesos em múltiplas linhas:
```bash
$ ./eSapiensAlg 6 \
> 16 18 12 6 1 25
```

![pesos multiline](https://i.imgur.com/qb3bo7d.png)
Observação: é necessário um espaço antes do `\` ou, alternativamente, na segunda linha antes do primeiro peso; do contrário o primeiro peso é concatenado a quantidade de caixas, o que, nesse exemplo, resultaria em erro, pois seriam informadas 616 caixas, mas somente 5 pesos.

#### Com logs de debug e execução de testes
```bash
$ ./eSapiensAlg 5 5 2 20 18 10 --debug
```
![debugging](https://i.imgur.com/yMtvgrD.png)

#### Especificando diferença máxima de peso
```bash
$ ./eSapiensAlg 5 "5 2 20 18 10" --weight=7

$ ./eSapiensAlg 5 5 2 20 18 10 --weight=7 --debug
```
![especificando peso](https://i.imgur.com/59fdACP.png)

#### Com entrada em arquivo
```bash
$ ./eSapiensAlg `cat <input_file>`
```
![de arquivo](https://i.imgur.com/IVMvzLu.png)

#### Sem argumentos (não indicado)
Roda em modo debug, com dados exemplo apresentados no enunciado do teste.
```bash
$ ./eSapiensAlg
```
![sem argumentos](https://i.imgur.com/H8JJqzB.png)

## Estrutura
*Per* enunciado, todo o código-fonte da aplicação está num único arquivo, *main.swift*.

Esse arquivo contém os seguintes elementos, na ordem:
- `BoxesError`: enum representando possíveis erros de execução do algoritmo.
- `checkBoxesWeightDiff(boxesWeights:maxDiff:)`: verifica se existe alguma diferença de peso entre as caixas que impossibilitaria o transporte.
- `checkBoxTransportPossibility(forWeights boxesWeights:maxWeightDiff:debugging:)`: função "principal", que determina se o conjunto de caixas pode ser transportado ou não; documentação quebra padrão para não deixar dúvidas.
- `Constants`: constantes para operação da aplicação.
- `ArgsError`: erro lançado ao carregar os argumentos CLI.
- `Args`: struct container de parâmetros de execução da aplicação, dados os argumentos CLI.
- instruções para execução da aplicação e verificação da possibilidade do transporte.

No Xcode, é possível configurar os argumentos CLI usados para executar a aplicação editando o esquema de execução. Isso é feito selecionando, na barra de tarefas, o combobox posicionado entre o botão "stop" e o combobox de dispositivo, daí a opção "Edit Scheme..." e, então, selecionando a aba "Arguments" na janela que abrir.

No projeto, há o esquema "eSapiensAlgArgs", que já contém alguns conjuntos de argumentos preparados, bastando selecionar quais deles se deseja usar nas próximas execuções.

-- Luiz Soares dos Santos Baglie (luizssb.biz {at} gmail {dot} com)