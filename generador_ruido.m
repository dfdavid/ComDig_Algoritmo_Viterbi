function ruido = generador_ruido( cantidad_de_muestras )
    for i=1:cantidad_de_muestras
        ruido(i,:)=randn(1,2);
        

end

