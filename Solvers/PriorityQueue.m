classdef PriorityQueue < handle
    %Naive priority queue implementation
    %   Higher indices are picked first
    
    properties
        list;
    end
    
    methods
        function obj = PriorityQueue()
            obj.list = {};
        end
        function obj = add(obj,object)
            obj.list{end+1} = object;
        end
        function popped = pop(obj,delta0)
            position = 1;
            highest = obj.list{1}.getIndex(delta0);
            for n = 2:length(obj.list)
                index = obj.list{n}.getIndex(delta0);
                if(index > highest)
                    position = n;                    
                    highest = index;
                end
            end
            popped = obj.list{position};
            obj.list(position) = [];
        end
    end
    
end

