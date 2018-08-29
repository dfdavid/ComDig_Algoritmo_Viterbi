function salida_canal = paso_por_canal(simbolos_fuente)
    % se asumen que al inicio las memorias del canal estan vacias (cero)
    b=0; % esto es bj-1
    c=0; % esto es bj-2
    for j=1:length(simbolos_fuente)
        salida_canal(j)=0.3*simbolos_fuente(j)+ b + 0.4*c;
        c=b;
        b=simbolos_fuente(j);
        
    end
end