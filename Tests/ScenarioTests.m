classdef ScenarioTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function numberEquationsMatchesVariables(testCase)
            scenario1;
            eqs = engine.numEquations(handler);
            vars = engine.numUnknowns(handler);
            testCase.verifyEqual(eqs,vars)
        end
        
        function evalFunctionScenario1(testCase)
            scenario1            
            fun((lb+ub)/2);
        end
        
    end
    
end

