clear all;
close all; 

%% %encoder

codeword=[1 -1 -1 1 1];

salidas=zeros(length(codeword),2);
%recorrido de la codeword
for j=1:length(codeword)
    
    bJota=codeword(j);
    %bJotaMenos1
    if j==1
        bJotaMenos1=1;
    else
        bJotaMenos1=codeword(j-1);
    end
    %bJotaMenos2
    if (j==1 || j==2)
        bJotaMenos2=1;
    else
        bJotaMenos2=codeword(j-2);
    end
    %mapa de codificacion
    xJotaMenos2=bJota*bJotaMenos2;
    xJotaMenos1=bJota*bJotaMenos1*bJotaMenos2;
    
    salidas(j,1)=xJotaMenos2;
    salidas(j,2)=xJotaMenos1;
end
%% decoder

numEstados=4;
profTruncamiento=5*numEstados;

satate_matrix=zeros(numEstados,numEstados*5);
cost_matrix=zeros(numEstados,length(codeword)+3);
