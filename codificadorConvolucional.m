%% encoder 
% simbolos_fuente es un vector cuyas componentes son una secuencia aleatoria de -1 y 1 
% salidas es una matriz que contiene las tuplas que el encoder genera una a
% una segun sean los simbolos_fuente y segun el diagrama de estados del
% codificador

function salidas=codificadorConvolucional(simbolos_fuente)

salidas=zeros(length(simbolos_fuente),2);
%recorrido de los simbolos_fuente
for j=1:length(simbolos_fuente)
    
    bJota=simbolos_fuente(j);
    %bJotaMenos1
    if j==1
        bJotaMenos1=1;
    else
        bJotaMenos1=simbolos_fuente(j-1);
    end
    
    %bJotaMenos2
    if (j==1 || j==2)
        bJotaMenos2=1;
    else
        bJotaMenos2=simbolos_fuente(j-2);
    end
    
    %mapa de codificacion (provee la misma informacion que el diagrama de estados, que "la arquitectura" y que el Trellis)
    xJotaMenos2=bJota*bJotaMenos2;
    xJotaMenos1=bJota*bJotaMenos1*bJotaMenos2;
    
    salidas(j,1)=xJotaMenos2;
    salidas(j,2)=xJotaMenos1;
end
%% decoder

% numEstados=4;
% profTruncamiento=5*numEstados;
% 
% satate_matrix=zeros(numEstados,numEstados*5);
% cost_matrix=zeros(numEstados,length(codeword)+3);
