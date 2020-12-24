# maxscore-estimator-mip-inR

Exact computation of Maximum Score estimator with Mixed Integer Programming via R code 

Use handy R code from the file main.R in order to exactly compute the Maxscore estimator with MIP. 
The main script sets up the matrices A,b,c,Aeq,beq,lb,ub of the MIP model, and then relies on a MIP solver to solve it.
We can use CPLEX with the Rcplex package. All functions are supplied in file functions.R. Also the contents of
file main.R can be wrapped up in a hypothetical function MaxScoreCompute.R (left for the user).

The dataset is read in readXyw function via the files X.txt, y.txt and w.txt which can be adopted as desired.
Currently, also weights w are supported for an extension called 'maximum weighted score estimator'.
In order to have a more flexible modeling approach, readers are suggested to consult the GAMS version
of the same model in https://www.gams.com/modlib/libhtml/mws.htm.

Feedback for the R code at cflorios@central.ntua.gr, cflorios@aueb.gr.

In case you have trouble installing Rcplex package, do not hesitate to contact me for support.

This is a translation of my own Matlab code available in another repository of mine (https://github.com/kflorios/maxscore-estimator-mip).

For completeness, I supply the Matlab manual here too.

Suggested publication:  

Florios, K., Skouras, S. 
Exact computation of max weighted score estimators
(2008) Journal of Econometrics, 146 (1), pp. 86-91.

http://www.sciencedirect.com/science/article/pii/S0304407608000778 
