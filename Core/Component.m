classdef Component
    %General component
    %   Provides an interface for calculating enthalpies and Cp's
    
    properties(Access = private)
        funCp;
        funH;
    end
    
    methods
        function y = cp(obj,T)
            y = feval(funCp,T);
        end
        function y = h(obj,T)
            y = feval(funH,T);
        end
    end
    
end

