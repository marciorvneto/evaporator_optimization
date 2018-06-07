classdef Node < handle
    %A node representing a subdomain
    
    properties
        lb;
        ub;
    end
    
    methods
        function obj = Node(lb,ub)
            obj.lb = lb;
            obj.ub = ub;
        end
        function m = centerPoint(obj)
            m = (obj.lb + obj.ub)/2;
        end
        function [n1,n2] = partition(obj)
            [~,index] = max(obj.ub-obj.lb);
            n1 = Node(obj.lb,obj.ub);
            n1.ub(index) = (obj.lb(index)+obj.ub(index))/2;
            n2 = Node(obj.lb,obj.ub);
            n2.lb(index) = (obj.lb(index)+obj.ub(index))/2;
        end
        function index = getIndex(obj,delta0)
            [index,~] = max((obj.ub-obj.lb)./delta0);
        end
    end
    
end

