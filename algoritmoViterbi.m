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

%% COST_MATRIX 
%esta matriz guarda el costo acumulado en cada estado, no es necesario que
%se guarde el historico de los costos de estados. Se puede implementar como
%un vector: [cantEstados,1]

% cost_matrix=randi(20,4,7); 
cost_matrix=zeros(4,1); %inicializo la matriz de costos





%si la state_matrix esta llena se llama a traceback

while 1
    
    if length(state_matrix)>=tamVentana
    simbolo=traceback(state_matrix,cost_matrix,tamVentana,Estados);
    end
    disp('el simbolo decodificado es: ')
    disp(simbolo)
end
