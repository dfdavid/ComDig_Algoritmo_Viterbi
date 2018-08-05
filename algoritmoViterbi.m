clear all 
close all
clc

%% SECUENCIA DE SIMBOLOS


% simbolos_fuente=[-1 -1 -1 -1 ];  %esta es una secuencia  arbitraria de  bits que seran codificados con la maquina de estados de ejemplo del libro de Bixio Rimoldi
% simbolos_fuente=[-1 -1 -1 1 ];
% simbolos_fuente=[-1 -1 1 -1 ];
% simbolos_fuente=[-1 -1 1 1 ];
% simbolos_fuente=[-1 1 -1 -1 ]; %% este dio error en el traceback
% simbolos_fuente=[-1 1 -1 1 ]; %% este dio error en el traceback
% simbolos_fuente=[-1 1 1 -1 ]; %% este dio error en el traceback
% simbolos_fuente=[-1 1 1 1 ]; %% este dio error en el traceback
% simbolos_fuente=[1 -1 -1 -1 ]; %% este dio error en el traceback
% simbolos_fuente=[1 -1 -1 1 ]; %% este dio error en el traceback
% simbolos_fuente=[1 -1 1 -1 ];
% simbolos_fuente=[1 -1 1 1 ];
% simbolos_fuente=[1 1 -1 -1 ];
% simbolos_fuente=[1 1 -1 1 ];
% simbolos_fuente=[1 1 1 -1 ];
% simbolos_fuente=[1 1 1 1 ];

y_matrix=codificadorConvolucional(simbolos_fuente);




%% Trellis provisto como matriz
%       [State, PrevStateEdge1, PrevStateEdge2, Input, OutputEdge1, OutputEdge2]
Trellis=[1             1              3          0       1     1       -1   1
         2             1              3          0      -1    -1        1   1
         3             2              4          0       1    -1       -1   1
         4             2              4          0      -1     1        1  -1
         ];
%% VARIABLES NECESARIAS
tamVentana=3; %es igual a la profundidad de truncamiento (normalmente es cantEstados*5)
Estados=[ 1  1;
         -1  1;
          1 -1;
         -1 -1]; % Esta matriz guarda los estados posibles del Trellis

%% STATE_MATRIX
% R = randi(IMAX,N) returns an N-by-N matrix containing pseudorandom
%     integer values drawn from the discrete uniform distribution on 1:IMAX.
%     randi(IMAX,M,N) or randi(IMAX,[M,N]) returns an M-by-N matrix.

% state_matrix=randi(4,4,7);
state_matrix=zeros(4,tamVentana); %aca se inicializa la matriz de estados
state_matrix(1,1)=1; %el sistema inicia desde el estado S1 (ver Trellis completo)

%% COST_VECTOR 
%este vector guarda el costo acumulado en cada estado, no es necesario que
%se guarde el historico de los costos de estados. Se puede implementar como
%un vector: [cantEstados,1]

cost_vector=zeros(4,1); %inicializo el vector de costos
cost_vector_nuevo=zeros(4,1); %este auxiliar lo uso para no alter el valor 
                              %del cost_vector original durante los calculos. 
                              %Por ejemplo, ver la iteracion j=3 en el
                              %estado s2, el cost_vector(1) cambio, y lo necesito sin cambios para los siguientes if




%% ALGORITMO DE VITERBI DECODIFICADOR
% voy recorriendo de a una las tuplas recibidas y lleno la state_matrix y
% el cost_vector iteracion tras iteracion

dimension=size(y_matrix);
cantFilas=dimension(1); %cantidad de tuplas que se recibieron


%% Estado inicial del Trellis y período transitorio

for j=1:3 % el 3 esta hardcodeado, ya que si el Trellis tuviera mas estados ese valor es funcion de la cantidad de estados
    
    %si el sistema esta iniciando, se asume que parte del estado 1 de la
    %primera iteracion del Trellis
    
    if j==1 %si se trata de la primera tupla, asumo que el sistema se inicia en el estado 1
        cost_vector(1)= 0; % 
        state_matrix(1,1)=1; % al inicio no existe otra psibilidad para el estado previo por eso es =1
    end
    
    if j==2
            for e=1:2 % en la segunda tupla recibida despues de un reset solo podran ser alcanzados los dos primeros estados
                if e==1
                    cost_vector(1)=y_matrix(j,:)*Trellis(1,(5:6))';
                    state_matrix(1,2)=1; % en esta iteracion solo se puede llegar a s1 desde s1
                end
                
                if e==2
                    cost_vector(2)=y_matrix(j,:)*Trellis(2,(5:6))'; % en esta iteración la metrica de estado solo ha acumulado la metrica de la unica rama que atravezó
                    state_matrix(2,2)=1; %  en esta iteracion solo se puede llegar a s2 desde s1
                end
            end
    end
    
    if j==3
        for e=1:4 % este 4 esta hardcodeado
            if e==1
                cost_vector_nuevo(1)=cost_vector(1)+y_matrix(j,:)*Trellis(1,(5:6))'; %la metrica de estao en esta iteracion corresponde a la metrica actual + la metrica de rama
                state_matrix(1,3)=1; % en la iteración 3 solo puedo llegar a s1 desde s1
            end
            
            if e==2 %ojo porque aca el cost_vector(1) cambio, y lo necesito sin cambios para los siguientes if
                cost_vector_nuevo(2)=cost_vector(1)+y_matrix(j,:)*Trellis(2,(5:6))'; % la metrica de estado es la metrica del estado previo + la metrica de ramma hasta s2 en este caso
                state_matrix(2,3)=1; % en la iteracion 3, solo se llega a s2 desde s1
            end
            
            if e==3
                cost_vector_nuevo(3)=cost_vector(2)+y_matrix(j,:)*Trellis(3,(5:6))';
                state_matrix(3,3)=2; %en esta iteración solo se puede alcanzar s3 desde s2
            end
            
            if e==4
                cost_vector_nuevo(4)=cost_vector(2)+y_matrix(j,:)*Trellis(4,(5:6))'; % la metrica de estado es cost_vector s2 + metrica de rama
                state_matrix(4,3)=2;  %en la iteración 3 solo se puede alcanzar s4 desde s2
            end
                        
        end % fin del recorrido de estados en esta iteracion
        
        for i=1:length(cost_vector) % en este for cargo definitivamente el cost_vector con los valores nuevos obtenidos para la iteracion 3
            cost_vector(i)=cost_vector_nuevo(i);
        end
        
    end % fin del if j==3, dentro del recorrido por las iteraciones de j=1:3
end % fin del transitorio
            
%se llama a traceback por primera vez (con ventana de 3 iteraciones)    
simbolo=traceback(state_matrix, cost_vector, tamVentana, Estados);
disp('el simbolo decodificado es: ')
disp(simbolo)

	    
      
%% Aca comienza el estado de regimen  del Trellis      
%       %       cuando el sistema entra en regimen, en este caso para j=4 en adelante
%       %       se recorren todos los estados para calcular la metrica de estado
% 
% 
% for e=1:length(Estados) %
%     
%     if e==1 %entonces puedo venir de s1 o  s3
%         metrica_r1=y_matrix(j,:)*Trellis(1,(5:6))';
%         costo_total1= cost_vector(e)+metrica_r1;
%         
%         metrica_r3=y_matrix(j,:)*Trellis(3,(7:8))';
%         costo_total3=cost_vector(3)+ metrica_r3;
%         
%         if costo_total1 > costo_total3
%             cost_vector(e) =  costo_total1;
%             state_matrix(e,j) = 1;
%         else
%             cost_vector(e) = costo_total3;
%             state_matrix(e,j) = 3;
%         end
%     end
%     
%     if e==2 %aca se consideran las ramas que llegan al s2
%         costo_rama1=y_matrix(j,:)*Trellis(e,(5:6))';
%         costo_camino1=cost_vector(1)+costo_rama1;
%         
%         costo_rama3=y_matrix(j,:)*Trellis(e,(7:8))';
%         costo_camino3=cost_vector(3)+costo_rama3;
%         
%         if costo_camino1 > costo_camino3
%             cost_vector(e)=costo_camino1;
%             state_matrix(e,j)=1;
%         else
%             cost_vector(e)=costo_camino3;
%             state_matrix(e,j)=3;
%         end
%     end % fin calculo de metrica de s2
%     
%     
%     if e==3 %aca considero las ramas que llegan al s3
%         % metricas de rama y de camino para los dos estados prev
%         costo_rama2=y_matrix(j,:)*Trellis(2,(5:6))';
%         costo_camino2=cost_vector(2)+costo_rama2;
%         
%         costo_rama4=y_matrix(j,:)*Trellis(e,(7:8))';
%         costo_camino4=cost_vector(4)+costo_rama4;
%         %-------------------------------------------------------
%         if costo_camino2 > costo_camino4   %se comparan las metricas de camino (cost_vector() + metrica de rama) y se selecciona la mayor
%             cost_vector(e)=costo_camino2;  %se actualiza el cost_vector con el costo del mayor camino (sobreviviente)
%             state_matrix(e,j)=2;           %se carga la  state_matrix con el numero de estado previo, (el estado desde el cual se llego)
%         else                               %
%             cost_vector(e)=costo_camino4;  %
%             state_matrix(e,j)=4;           %
%         end
%     end  % fin calculo de metrica de s3
%     
%     if e==4 %aca considero las ramas que llegan a s4
%         costo_rama2=y_matrix(j,:)*Trellis(e,(5:6))';
%         costo_camino2=cost_vector(2)+costo_rama2;
%         
%         costo_rama4=y_matrix(j,:)*Trellis(e,(7:8))';
%         costo_camino4=cost_vector(4)+costo_rama4;
%         %-----------------------------------------------------
%         if costo_camino2 > costo_camino4
%             cost_vector(e)=costo_camino2;
%             state_matrix(e,j)=2;
%         else
%             cost_vector(e)=costo_camino4;
%             state_matrix(e,j)=4;
%         end
%     end
% end
% 
% %este bloque if se ejecuta solo una vez, cuando se llena por primera vez la state_matrix
% if j>=tamVentana
%     %En este punto se llama a 'traceback'
%     simbolo_decodificado=traceback(state_matrix, cost_vector, tamVentana, Estados);
%     disp('el simbolo decodificado es: ') % esto podria estar dentro de la funcion TRACEBACK
%     disp(simbolo_decodificado)           %
%     %en este punto se llama a 'shift'
%     state_matrix=shift(state_matrix);
% end
% 
% %end
% 
% %j=tamVentana+1;      no incremento 'j' aca porque lo hago dentro del ciclo
% %while
% ultimaCol=tamVentana;
% while j<length(y_matrix) %debo considerar sumarle el retardo que tiene al inicializar, PROBAR CON length(y_matrix+2)
%     j=j+1;
%     %llamar al llenador de matrices o escribirlo aqui
%     for e=1:length(Estados)                              %
%         costA=y_matrix(j,:)*Trellis(e,(5:6))';           %
%         costB=y_matrix(j,:)*Trellis(e,(7:8))';           %
%         if costA > costB                                 %   ESTE ES EL BLOQUE LLENADOR DE COST_VECTOR Y
%             cost_vector(e)=cost_vector(e)+costA;         %                                 SATATE_MATRIX
%             state_matrix(e,tamVentana)=Trellis(e,2);     %
%         else                                             %
%             cost_vector(e)=cost_vector(e)+costB;         %
%             state_matrix(e,tamVentana)=Trellis(e,3);     %
%         end                                              %
%     end                                                  %
%     
%     %llamar a traceback
%     simbolo_decodificado=traceback(state_matrix,cost_vector, tamVentana, Estados);
%     disp('El simbolo decodificado es: ')
%     disp(simbolo_decodificado)
%     
%     %llamar a shift
%     state_matrix=shift(state_matrix);
% end

