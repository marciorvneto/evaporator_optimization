function h = hLiq(stream,x,T)
%Calculates the enthalpy of liquid streams

    if(strcmp(stream.subtype,'BLIQ'))
        h = cp(x,T)*T;
    else
        h = hSatL_T(T);
        
    end

end

