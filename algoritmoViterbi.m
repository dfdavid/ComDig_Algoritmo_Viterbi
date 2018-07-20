clear all 
close all

%% SECUENCIA DE SIMBOLOS

simbolos=[1 1 1 -1 1 -1 -1 1];  %esta es una secuencia es arbitraria de 8 bits

%% TRELLIS provisto como matriz
%       [State, PrevStateEdge1, PrevStateEdge2, Input, OutputEdge1, OutputEdge2]
Trellis=[1             1              3         -1       1    -1       -1   1
         2             1              3          1      -1    -1        1  -1
         3             2              4         -1       1     1       -1  -1
         4             2              4          1      -1    -1        1   1
         ];
%% VARIABLES NECESARIAS
tamVentana=3; %es igual a la profundidad de truncamiento (normalmente es cantEstados*5)
Estados=[-1 -1;
         -1  1;
          1 -1;
          1  1] % Esta matriz guarda los estados posibles del trellis

%% STATE_MATRIX
% R = randi(IMAX,N) returns an N-by-N matrix containing pseudorandom
%     integer values drawn from the discrete uniform distribution on 1:IMAX.
%     randi(IMAX,M,N) or randi(IMAX,[M,N]) returns an M-by-N matrix.

% state_matrix=randi(4,4,7);
state_matrix=zeros(4,tamVentana); %aca se inicializa la matriz de estados

%% COST_VECTOR 
%este vector guarda el costo acumulado en cada estado, no es necesario que
%se guarde el historico de los costos de estados. Se puede implementar como
%un vector: [cantEstados,1]

% cost_matrix=randi(20,4,7); 
cost_vector=zeros(4,1); %inicializo la matriz de costos





% voy recorriendo de a una las tuplas recibidas y lleno la state_matrix y
% el cost_vector iteracion tras iteracion

dimension=size(y_matrix);
cantFilas=dimension(1);

for j=1:cantFilas %aca inicio el recorrido por las tuplas
    
    %si el sistema esta iniciando, se asume que parte del estado 1 de la
    %primera iteracion del trellis
    
    if j==1 %si se trata de la primera tupla, asumo que el sistema se inicia en el estado 1
            costA=y_matrix(j)*trellis(e,[5:6]); %este es el producto punto entre la tupla recibida y el peso de la rama
            costB=y_matrix(j)*trellis(e,[7:8]);
            cost_vector(e)=max(costA,costB);
            state_matrix(1,1)=1; % al inicio no existe otra psibilidad para el estado previo por eso es =1
    end
    
    if j==2
        for e2=1:2 % en la segunda tupla recibida despues de un reset solo podran ser alcanzados los dos primeros estados
           costA=recibido(j)*trellis(e2,(5:6));
           costB=recibido(j)*trellis(e2,(7:8));
           %en el siguiente bloque 'if' se determina: 
           % -la mayor metrica de estado (la guardo en el cost vector) y,
           % -cual es el estado de procedencia (lo guardo en la state_matrix)
           if costA > costB
               cost_vector(e2)=cost_vector(e2)+ costA;
               state_matrix(e2,j)= trellis(e2,2);
           else
               cost_vector(e2)=cost_vector(e2)+ costB;
               state_matrix(e2,j)= trellis(e2,3);
           end
        end
    end
    
    %cuando el sistema entra en regimen, en este caso para j=3 en adelante
    %se recorren todos los estados para calcular la metrica de estado
    for e=1:length(Estados)
           costA=recibido(j)*trellis(e2,(5:6));
           costB=recibido(j)*trellis(e2,(7:8));
           
           if costA > costB
               cost_vector(e)=cost_vector(e)+ costA;
               state_matrix(e,j)=trellis(e,2);
           else 
               cost_vector(e)=cost_vector(e)+costB;
               state_matrix(e,j)=trellis(e,3);
           end
    end
    
    if j>=tamventana
        simbolo_decodificado=traceback(state_matrix, cost_vector, tamventana, Estados);
        disp('el simbolo decodificado es: ')
        disp(simbolo_decodificado)
        
        %shift state_matrix
        state_matrix=[state_matrix(:,(2:tamVentana),zeros(length(Estados),1))];
    end
    
end
