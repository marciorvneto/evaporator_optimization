classdef Source < Block
    %Source block
        % For now, this is class is only meant for the adjacency matrices
        % to be graphable.    
    properties

    end
    
    methods
        function obj = Source()
            obj = obj@Block('SOU');
        end
    end
    
end

