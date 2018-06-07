classdef Sink < Block
    %Sink block
        % For now, this is class is only meant for the adjacency matrices
        % to be graphable.
    
    properties
    end
    
    methods
        function obj = Sink()
            obj = obj@Block('SIN');

        end
    end
    
end

