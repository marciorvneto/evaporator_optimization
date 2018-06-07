clear all, close all, clc

% Unit testing the derivative-related functions

%% 1D

constant1D = @(x) 1;
linear1D = @(x) 3*x-2;
quadratic1D = @(x) x^2-2*x+3;

assert(closeTo(numericalDerivative(constant1D,10,1e-5),0,1e-6),'Failed to evaluate constant1D')
assert(closeTo(numericalDerivative(linear1D,10,1e-5),3,1e-6),'Failed to evaluate linear1D')
assert(closeTo(numericalDerivative(quadratic1D,10,1e-5),18,1e-6),'Failed to evaluate quadratic1D')

%% ND

combinedND = @(x) x(1)^2-x(1)*x(2)+5*x(2)-4;

assert(closeTo(numericalDerivativeND(combinedND,[10;5],2,1,1e-5),15,1e-6),'Failed to evaluate 1st var');
assert(closeTo(numericalDerivativeND(combinedND,[10;5],2,2,1e-5),-5,1e-6),'Failed to evaluate 1st var');

%% Jacobian

J = numericalJacobian('testMixedFcn',3,[1;2;3],1e-5);

%% Homotopy

res = solveHomotopy('testSystem',2,[1;1],1e-5);

%% Global NR

res = solveGlobalNR('testSystem',[1;1],2,1.2);