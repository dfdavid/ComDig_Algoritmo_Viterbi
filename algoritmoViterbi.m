clear all 
% close all
format long
clc

iter=0; %inicializo el indice de iternaciones que uso para el vector BER
SNRmin=0;
Espac=0.25;
SNRmax=10;
for SNR=SNRmin:Espac:SNRmax %repito la simulacion para obtener  distintos valores de BER vs SNR
    iter = iter+1;
    %% SECUENCIA DE SIMBOLOS
    % esta es una secuencia  aleatoria de  bits que seran codificados con la 
    % maquina de estados de ejemplo del libro de Bixio Rimoldi

    simbolos_fuente=2*randi([0,1],1,10000)-1;


    %en la sieguiente linea se llama a la funcion 'codificadorConvolucional'
    %que codifica los bits fuente en tuplas de acuerdo al mapa de codificacion
    %especificado en su propio codigo, en este caso, es el que propone Bixio
    %Rimoldi
    simbolos_codificados=codificadorConvolucional(simbolos_fuente); %ORIGINAL


    % generacion de ruido AWGN 
        % ruido=generador_ruido(length(simbolos_codificados),SNR);
        % stem(ruido)
        % ruido=ruido*1;
        % simbolos_codificados=simbolos_codificados+ruido;

    % Aca se le a�ade el ruido
        %SNR=3;
        simbolos_codificados=awgn(simbolos_codificados,SNR);
        % stem(simbolos_codificados)




    %se inicializa el vector que contiene los simbolos decodificados que se ira
    %llenando con las sucesivas llamadas a traceback
    simbolos_decodificados=zeros(1, length(simbolos_fuente));




    %% Trellis provisto como matriz
    %       [State, PrevStateEdge1, PrevStateEdge2, Input, OutputEdge1, OutputEdge2]
    Trellis=[1             1              3          0       1     1       -1  -1
             2             1              3          0      -1    -1        1   1
             3             2              4          0       1    -1       -1   1
             4             2              4          0      -1     1        1  -1
             ];
    %% VARIABLES NECESARIAS
    tamVentana=6; %es igual a la profundidad de truncamiento (normalmente es cantEstados*5)
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
    % state_matrix(1,1)=1; %el sistema inicia desde el estado S1 (ver Trellis completo)

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

    % dimension=size(simbolos_codificados);
    % cantFilas=dimension(1); %cantidad de tuplas que se recibieron


    %% 1 %% Estado inicial del Trellis y per�odo transitorio

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
                        cost_vector(1)=simbolos_codificados(j-1,:)*Trellis(1,(5:6))'; % se pone j-1 porque si estamos en j=2 la tupla recibida es la primera, y els la que provoco el salto al s1 nuevamente
                        state_matrix(1,2)=1; % en esta iteracion solo se puede llegar a s1 desde s1
                    end

                    if e==2
                        cost_vector(2)=simbolos_codificados(j-1,:)*Trellis(2,(5:6))'; % en esta iteraci�n la metrica de estado solo ha acumulado la metrica de la unica rama que atravez�. Se pone j-1 porque si estamos en j=2 la tupla recibida es la 1� , y es la que provoco el salto al s2
                        state_matrix(2,2)=1; %  en esta iteracion solo se puede llegar a s2 desde s1
                    end
                end
        end

        if j==3
            for e=1:4 % este 4 esta hardcodeado
                if e==1
                    cost_vector_nuevo(1)=cost_vector(1)+simbolos_codificados(j-1,:)*Trellis(1,(5:6))'; %la metrica de estao en esta iteracion corresponde a la metrica actual + la metrica de rama
                    state_matrix(1,3)=1; % en la iteraci�n 3 solo puedo llegar a s1 desde s1
                end

                if e==2 %ojo porque aca el cost_vector(1) cambio, y lo necesito sin cambios para los siguientes if
                    cost_vector_nuevo(2)=cost_vector(1)+simbolos_codificados(j-1,:)*Trellis(2,(5:6))'; % la metrica de estado es la metrica del estado previo + la metrica de ramma hasta s2 en este caso
                    state_matrix(2,3)=1; % en la iteracion 3, solo se llega a s2 desde s1
                end

                if e==3
                    cost_vector_nuevo(3)=cost_vector(2)+simbolos_codificados(j-1,:)*Trellis(3,(5:6))';
                    state_matrix(3,3)=2; %en esta iteraci�n solo se puede alcanzar s3 desde s2
                end

                if e==4
                    cost_vector_nuevo(4)=cost_vector(2)+simbolos_codificados(j-1,:)*Trellis(4,(5:6))'; % la metrica de estado es cost_vector s2 + metrica de rama
                    state_matrix(4,3)=2;  %en la iteraci�n 3 solo se puede alcanzar s4 desde s2
                end

            end % fin del recorrido de estados en esta iteracion

            for i=1:length(cost_vector) % en este for cargo definitivamente el cost_vector con los valores nuevos obtenidos para la iteracion 3
                cost_vector(i)=cost_vector_nuevo(i);
            end

        end % fin del if j==3, dentro del recorrido por las iteraciones de j=1:3
    end % fin del transitorio

    % en versiones anteriores del este algoritmo el tam de ventana era 3, en
    % ese caso se llamaba a traceback en este punto
    if j>= tamVentana
        simbolo=traceback(state_matrix, cost_vector, tamVentana, Estados);
    %     disp('el simbolo decodificado es: ')
    %     disp(simbolo)
        simbolos_decodificados(1,j-2)=simbolo; % la decodificacion tiene retardo, por eso se pone j-2
    end

    %% 2 %% En este punto comienza el llenado de la ventana
    while j<tamVentana %aqui se continua desde que termina el transitorio hasta que se llena completamente la ventana
        j=j+1;

        %Se llama al llenador de matrices:
            %"bloque llenador" (de 'cost_vector' y 'state_matrix')
            for e=1:length(Estados) %

                if e==1 %entonces puedo venir de s1 o  s3
                    metrica_r1=simbolos_codificados(j-1,:)*Trellis(1,(5:6))';
                    costo_total1= cost_vector(e)+metrica_r1;

                    metrica_r3=simbolos_codificados(j-1,:)*Trellis(1,(7:8))';
                    costo_total3=cost_vector(3)+ metrica_r3;

                    if costo_total1 > costo_total3
                        cost_vector_nuevo(e) =  costo_total1;
                        state_matrix(e,j) = 1; % siempre se escribe la ultima coluna de la ventana por el shift 
                    else
                        cost_vector_nuevo = costo_total3;
                        state_matrix(e,j) = 3;
                    end
                end

                if e==2 %aca se consideran las ramas que llegan al s2
                    costo_rama1=simbolos_codificados(j-1,:)*Trellis(e,(5:6))';
                    costo_camino1=cost_vector(1)+costo_rama1;

                    costo_rama3=simbolos_codificados(j-1,:)*Trellis(e,(7:8))';
                    costo_camino3=cost_vector(3)+costo_rama3;

                    if costo_camino1 > costo_camino3
                        cost_vector_nuevo(e)=costo_camino1;
                        state_matrix(e,j)=1;
                    else
                        cost_vector_nuevo(e)=costo_camino3;
                        state_matrix(e,j)=3;
                    end
                end % fin calculo de metrica de s2


                if e==3 
                    % metricas de rama y de camino para los dos estados prev
                    costo_rama2=simbolos_codificados(j-1,:)*Trellis(3,(5:6))';
                    costo_camino2=cost_vector(2)+costo_rama2;

                    costo_rama4=simbolos_codificados(j-1,:)*Trellis(e,(7:8))';
                    costo_camino4=cost_vector(4)+costo_rama4;
                    %-------------------------------------------------------
                    if costo_camino2 > costo_camino4   %se comparan las metricas de camino (cost_vector() + metrica de rama) y se selecciona la mayor
                        cost_vector_nuevo(e)=costo_camino2;  %se actualiza el cost_vector con el costo del mayor camino (sobreviviente)
                        state_matrix(e,j)=2;           %se carga la  state_matrix con el numero de estado previo, (el estado desde el cual se llego)
                    else                               %
                        cost_vector_nuevo(e)=costo_camino4;  %
                        state_matrix(e,j)=4;           %
                    end
                end  % fin calculo de metrica de s3

                if e==4 %aca considero las ramas que llegan a s4
                    costo_rama2=simbolos_codificados(j-1,:)*Trellis(e,(5:6))';
                    costo_camino2=cost_vector(2)+costo_rama2;

                    costo_rama4=simbolos_codificados(j-1,:)*Trellis(e,(7:8))';
                    costo_camino4=cost_vector(4)+costo_rama4;
                    %-----------------------------------------------------
                    if costo_camino2 > costo_camino4
                        cost_vector_nuevo(e)=costo_camino2;
                        state_matrix(e,j)=2;
                    else
                        cost_vector_nuevo(e)=costo_camino4;
                        state_matrix(e,j)=4;
                    end
                end
            end

            %actualizacion del cost_vector
            for i=1:length(cost_vector)
                cost_vector(i)=cost_vector_nuevo(i);
            end
    end
    %% 3 - 4 %% 
    if j>=tamVentana
        %llamar a traceback
        simbolo=traceback(state_matrix,cost_vector, tamVentana, Estados);
    %     disp('El simbolo decodificado es: ')
    %     disp(simbolo)
        simbolos_decodificados(1,(j-(tamVentana-1)))=simbolo;

        %llamar a shift
        state_matrix=shift(state_matrix);
    end

    %% 5 %% Aca comienza el estado de regimen  del Trellis      
    %       cuando el sistema entra en regimen, en este caso para j=4 en adelante
    %       se recorren todos los estados para calcular la metrica de estado

    while j<length(simbolos_codificados)+1 %debo considerar sumarle el retardo que tiene al inicializar, PROBAR CON length(simbolos_codificados+2)
        j=j+1;

        %Se llama al llenador de matrices:
            %"bloque llenador" (de 'cost_vector' y 'state_matrix')
            for e=1:length(Estados) %

                if e==1 %entonces puedo venir de s1 o  s3
                    metrica_r1=simbolos_codificados(j-1,:)*Trellis(1,(5:6))';
                    costo_total1= cost_vector(e)+metrica_r1;

                    metrica_r3=simbolos_codificados(j-1,:)*Trellis(1,(7:8))';
                    costo_total3=cost_vector(3)+ metrica_r3;

                    if costo_total1 > costo_total3
                        cost_vector_nuevo(e) =  costo_total1;
                        state_matrix(e,tamVentana) = 1; % siempre se escribe la ultima coluna de la ventana por el shift 
                    else
                        cost_vector_nuevo = costo_total3;
                        state_matrix(e,tamVentana) = 3;
                    end
                end

                if e==2 %aca se consideran las ramas que llegan al s2
                    costo_rama1=simbolos_codificados(j-1,:)*Trellis(e,(5:6))';
                    costo_camino1=cost_vector(1)+costo_rama1;

                    costo_rama3=simbolos_codificados(j-1,:)*Trellis(e,(7:8))';
                    costo_camino3=cost_vector(3)+costo_rama3;

                    if costo_camino1 > costo_camino3
                        cost_vector_nuevo(e)=costo_camino1;
                        state_matrix(e,tamVentana)=1;
                    else
                        cost_vector_nuevo(e)=costo_camino3;
                        state_matrix(e,tamVentana)=3;
                    end
                end % fin calculo de metrica de s2


                if e==3 
                    % metricas de rama y de camino para los dos estados prev
                    costo_rama2=simbolos_codificados(j-1,:)*Trellis(3,(5:6))';
                    costo_camino2=cost_vector(2)+costo_rama2;

                    costo_rama4=simbolos_codificados(j-1,:)*Trellis(e,(7:8))';
                    costo_camino4=cost_vector(4)+costo_rama4;
                    %-------------------------------------------------------
                    if costo_camino2 > costo_camino4   %se comparan las metricas de camino (cost_vector() + metrica de rama) y se selecciona la mayor
                        cost_vector_nuevo(e)=costo_camino2;  %se actualiza el cost_vector con el costo del mayor camino (sobreviviente)
                        state_matrix(e,tamVentana)=2;           %se carga la  state_matrix con el numero de estado previo, (el estado desde el cual se llego)
                    else                               %
                        cost_vector_nuevo(e)=costo_camino4;  %
                        state_matrix(e,tamVentana)=4;           %
                    end
                end  % fin calculo de metrica de s3

                if e==4 %aca considero las ramas que llegan a s4
                    costo_rama2=simbolos_codificados(j-1,:)*Trellis(e,(5:6))';
                    costo_camino2=cost_vector(2)+costo_rama2;

                    costo_rama4=simbolos_codificados(j-1,:)*Trellis(e,(7:8))';
                    costo_camino4=cost_vector(4)+costo_rama4;
                    %-----------------------------------------------------
                    if costo_camino2 > costo_camino4
                        cost_vector_nuevo(e)=costo_camino2;
                        state_matrix(e,tamVentana)=2;
                    else
                        cost_vector_nuevo(e)=costo_camino4;
                        state_matrix(e,tamVentana)=4;
                    end
                end
            end


            for i=1:length(cost_vector)
                cost_vector(i)=cost_vector_nuevo(i);
            end

        if j>=tamVentana
        %llamar a traceback
            simbolo=traceback(state_matrix,cost_vector, tamVentana, Estados);
    %         disp('El simbolo decodificado es: ')
    %         disp(simbolo)
            simbolos_decodificados(1,(j-(tamVentana-1)))=simbolo;

        %llamar a shift
            state_matrix=shift(state_matrix);    
        end


    end

    %% Contador de errores

    %inicializo la cuenta de errores
    errores_de_bit=0;

    for i=1:length(simbolos_decodificados)-4
        if simbolos_decodificados(i)==simbolos_fuente(i)
            % si son iguales no hay error -> no se hace nada
        else
            errores_de_bit=errores_de_bit+1;
        end
    end
    
    SNRvec(iter)=SNR; 
    BER(iter)=errores_de_bit/(length(simbolos_fuente)-4)
    
    
    %% Limite de error superior teorico:
    %https://la.mathworks.com/help/comm/ug/bit-error-rate-ber.html#fp13269
    
    dspec.dfree = 10; % Minimum free distance of code
    dspec.weight = [ 0 1  2 4 8 16 32 64 128 512 1024 2048 4096]; % Distance spectrum of code
    SNRt=SNRmin:1:SNRmax;
    %SNRt=[1 2 3 4 5 6 7 8];
    berbound = bercoding(SNRt,'conv','hard',0.345,dspec);
    %berbound=[ 1 1 1e-1 1e-2 1e-3 1e-4 1.5e-6 1.1e-7  ];
        axis([1 SNRmax 10e-7 10e0])
        grid
        semilogy(SNRt,berbound,'b') % Plot the results.
        xlabel('SNR (dB)'); ylabel('Probabilidad de error');
        title('Limite de error superior teorico de BER (Codificador Convolucional)');
        hold on


    %% En este ultimo bloque se grafica el BER simulado      % SNR= Realacion Se�al Ruido: Es/No
    semilogy(SNR,BER(iter),'bx');                            % BER= Bit Error Rate: errores detectados/catidad transmitida
    legend('BER te�rico','BER simulado');
    hold on
    grid
        
end

    %% Curva de ajuste propuesta para los valores obtenidos de BER vs SNR
%     figure
%     semilogy(SNR,BER(iter),'bx'); 
%     hold on
    intervalos_SNR=SNRmin:Espac:SNRmax;
    berfit([SNRmin:Espac:SNRmax],BER,intervalos_SNR,[],'exp');
    %axis([-1 8 10e-8 10e0])
    legend('BER te�rico','BER simulado');
    xlabel('SNR [dB]'); ylabel('Probabilidad de error');
    title('BER vs. SNR[dB] curva ajustada a la simulaci�n');




    