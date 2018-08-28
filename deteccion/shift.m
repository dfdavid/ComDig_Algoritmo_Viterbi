function state_matrix_out=shift(state_matrix_in)

dimension=size(state_matrix_in);
filas=dimension(1);
columnas=dimension(2); %se podria utilizar una sola variable en lugar de tamVentana y columnas ya que son lo mismo, pero se dejan expresadas asi por claridad en la lectura del codigo
tamVentana=columnas;
state_matrix_out=state_matrix_in(:,(2:tamVentana));
            state_matrix_out(:,tamVentana)=zeros(filas,1);

end
