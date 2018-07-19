function s=traceback(state_matrix,cost_vector, tamVentana,Estados)
    dimensiones=size(state_matrix);
    nEstados=dimensiones(1);
%     nIteraciones=dimensiones(2);
    %determino en la ultima columna de state_matrix cual es el estado
    %inicial 
    for e=1:nEstados 
        %max=0; si le asigno cero aca siempre me pisa el valor de max de la
        %pasada anterior
        if e==1 %solo entro en la primera pasada para inicializar
            max=0;
        end
        if (cost_vector(e)>max )
            max=cost_vector(e);
            eInicial=e;
        end
    end
        
        %una vez conocido el estado inicial comienza el traceback
        for j=tamVentana:-1:1
            eAnterior=state_matrix(eInicial,j);
            simbolo=Estados(eInicial,1); %%Estados es una matriz cuyas filas son los estados posible y las columnas on las componentes de dichos estados
            if j==1
                s=simbolo;
            end
            eInicial=eAnterior;
        end
end
                
        
        
% end 