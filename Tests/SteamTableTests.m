classdef SteamTableTests < matlab.unittest.TestCase

    properties
    end
    
    methods (Test)
        function steamSaturationTemperature(testCase)            
            testCase.verifyLessThan(abs(Steam.satT(0.1)-0.372755919e3),1e-6);
            testCase.verifyLessThan(abs(Steam.satT(1)-0.453035632e3),1e-6);
            testCase.verifyLessThan(abs(Steam.satT(10)-0.584149488e3),1e-6);
        end
        function steamSaturationPressure(testCase)            
            testCase.verifyLessThan(abs(Steam.satP(300)-0.353658941e-2),1e-6);
            testCase.verifyLessThan(abs(Steam.satP(500)-0.263889776e1),1e-6);
            testCase.verifyLessThan(abs(Steam.satP(600)-0.123443146e2),1e-6);
        end
        function steamSaturationLiquidEnthalpyPositive(testCase)            
            testCase.verifyGreaterThan(Steam.hLSatT(300),0);
            testCase.verifyGreaterThan(Steam.hLSatP(1),0);
        end
        function steamSaturationVaporEnthalpyPositive(testCase)            
            testCase.verifyGreaterThan(Steam.hVSatT(300),0);
            testCase.verifyGreaterThan(Steam.hVSatT(300),Steam.hLSatT(300));
            testCase.verifyGreaterThan(Steam.hVSatP(1),0);
            testCase.verifyGreaterThan(Steam.hVSatP(1),Steam.hLSatP(1));
        end
        function steamEnthalpies(testCase)            
            testCase.verifyLessThan(abs(Steam.hV(300,0.0035)-0.254991145e4),1e-6);
            testCase.verifyLessThan(abs(Steam.hV(700,0.0035)-0.333568375e4),1e-6);
            testCase.verifyLessThan(abs(Steam.hV(700,30)-0.263149474e4),1e-6);
        end
    end
    
end

