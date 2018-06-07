# Evaporator Optimizer

## How it works

The optimizer emulates, to some extent, the inner workings of a process flowsheet simulator.

The users are allowed to define **Evaporators**, **Flash tanks**, **Liquid mixers**, **Vapor mixers**, **Liquid splitters**, **Vapor splitters**, and to connect them via **Black liquor streams**, **Vapor streams** and **Condensate streams**.

The engine essentialy provides the user with a black-box interface, whereby he provides a certain vector *x* to the engine as input. The entries of *x* correspond to variables such as temperatures, pressures and dissolved solid fractions pertaining to the system being modeled. As a response, the engine gives back another vector *f(x)*, which represents the collection of mass and energy balances that must be satisfied evaluated at *x*.

In other words, if the user inputs a vector *x* that satisfies all mass and energy balances, *f(x)* would have all its entries equal to zero.


## How to use

Please refer to the file in *Tests/Example.m* for a practical example on how to use the simulation engine. The example is self-explanatory. **It is extremely important** that the folder structure, starting from "Simulator" be kept intact, as all imported paths are relative.
