;; Código de função de subtração e adição com integer de 32 bits

;; Declarando o module, o "container" do código, onde tudo fica.
(module
    ;; Importanto a função callback de um código externo pois é onde esse código será utilizado.
    (import "math" "callback" (func $callback))

    ;; Função de soma que chama dois parâmetros integer de 32 bits a e b, e o resultado
    (func $add (param $a i32) (param $b i32) (result i32)
        local.get $a
        local.get $b
        i32.add
    )

    ;; Função de subtração que chama dois parâmetros integer de 32 bits a e b, e o resultado
    (func $subtract (param $a i32) (param $b i32) (result i32)
        local.get $a
        local.get $b
        i32.sub
    )

    ;; Exportando as funções de soma e subtração criadas
    (export "add" (func $add))
    (export "subtract" (func $subtract))
)

;; Código de Hello World do Wasm

(module

  ;; Importando função de jsprint pois é onde será utilizada em um código externo
  (import "env" "jsprint" (func $jsprint (param i32)))

  ;; Definindo a memoria para 64KB
  (memory $0 1)

  ;; Armazenando a string Hello World (com o final sendo null)
  (data (i32.const 0) "Hello World!\00")

  ;; Exportando a memoria para poder ser acessada no host container (que poderia ser um código JavaScript que usa a função).
  (export "pagememory" (memory $0))

  ;; Definindo a função que pode ser acessada pelo host
  (func $helloworld
    (call $jsprint (i32.const 0))
  )

  ;; Exportando a função de print para ser utilizada pelo host.
  (export "helloworld" (func $helloworld))
)

;;Exemplo de código com condicional em WebAssembly

;; Esse codígo testa se $x é menor que 10 para retornar um valor de 10, caso contrario ele retorna o valor de $x
 (module
  (func $min10 (param $x i32) (result i32)
  ;; Primeiro se testa se $x é menor que 10
   (if (result i32)
    (i32.lt_s
     (get_local $x)
     (i32.const 10)
    )
    (then
    ;; Se $x menor que 10 coloca o valor 10 no stack para ser retornado
     (i32.const 10)
    )
    (else
    ;; Caso contrário o valor de $x é colocado no stack para ser retornado
     (get_local $x)
    )
   )
  )  
  (export "min10" (func $min10))
) 

;;Exemplo de código recursivo em WebAssembly, calcula a ordem de Fibonacci recursivamente.

(module
;; fib é a chamada inicial com o parametro de quantas vezes o algoritmo teria que rodar.
  (func $fib (param i32) (result i32)
    (call $fib2 (get_local 0)
      (i32.const 0)   ;; Essas duas constantes seriam os "seed values" para a sequência de fibonacci.
      (i32.const 1)   
    )
  ) 
  ;; fib2 pega as 3 constantes anteriores para calcular fibonacci o número de vezes que foi passado 
  (func $fib2 (param $n i32) (param $a i32) (param $b i32) (result i32)
    (if (result i32)
      ;; eqz checa se o valor na memória é igual $n.
      (i32.eqz (get_local $n)
    )
    (then 
      (get_local $a)
    )
        (else 
        ;; Aqui fica a chamada recursiva da função onde o valor calculado é passado para a função novamente.
          (call $fib2 
            (i32.sub (get_local $n) (i32.const 1) )
            (get_local $b)
            (i32.add (get_local $a) (get_local $b) )
          )
        )
    )
  )
  (export "fib" (func $fib))
)

;; Para mostrar o real objetivo de WebAssembly segue o código compilado a partir do programa escrito em C abaixo:

(;;
int sumOfDigits(int n) {
  int sum = 0, remainder;

  while(n != 0){
    remainder = n%10;
    sum += remainder;
  	n = n/10;
  }

  return sum;
}
;;)

;; O programa recebe um número e acha a soma de seus digitos.

(module
 (table 0 anyfunc)
 (memory $0 1)
 (export "memory" (memory $0))
 ;; Exportando a função sumOfDigits para ser usado em um código externo.
 (export "sumOfDigits" (func $sumOfDigits))
 ;; Definindo a função sumOfDigits que recebe um parametro integer 32 bits e devolve um resultado do mesmo tipo.
 (func $sumOfDigits (; 0 ;) (param $0 i32) (result i32)
 ;; Criando duas variáveis na memória que corresponderiam 1 a sum e 2 a remainder no código C.
  (local $1 i32)
  (local $2 i32)
  (block $label$0
  ;; Criando a checagem de n == 0 que será usado no loop.
   (br_if $label$0
    (i32.eqz
     (get_local $0)
    )
   )
   (set_local $2
    (i32.const 0)
   )
   (loop $label$1 ;; esse label volta na checagem de n == 0 acima para ver se é necessário terminar ou continuar.
    (set_local $2
     (i32.add ;; Adicionando remainder com n%10 para atualizar seu valor. 
      (i32.rem_s
       (get_local $0)
       (i32.const 10)
      )
      (get_local $2)
     )
    )
    (set_local $1
     (i32.add ;; Era pra ser sum += remainder, mas não sei como isso está acontecendo aqui, pelo que eu entendi parece que ele pega o valor de n e adiciona 9 para colocar no sum, não sei como está funcionando.
      (get_local $0)
      (i32.const 9)
     )
    )
    (set_local $0
     (i32.div_s ;; Fazendo a divisão n = n/10.
      (get_local $0)
      (i32.const 10)
     )
    )
    (br_if $label$1 ;; Voltando a label criado em cima no inicio do loop caso n ainda não seja 0.
     (i32.gt_u
      (get_local $1)
      (i32.const 18)
     )
    )
   )
   (return ;; retornando a váriavel que corresponde a sum após finalizar o algoritmo.
    (get_local $2)
   )
  )
  (i32.const 0)
 )
)

;; E esse seria o código JS para ativar o programa wasm compilado em uma situação real:

(;;
var wasmModule = new WebAssembly.Module(wasmCode);
var wasmInstance = new WebAssembly.Instance(wasmModule, wasmImports);
log(wasmInstance.exports.sumOfDigits(5245));
log(wasmInstance.exports.sumOfDigits(31));
log(wasmInstance.exports.sumOfDigits(934302));
;;)
