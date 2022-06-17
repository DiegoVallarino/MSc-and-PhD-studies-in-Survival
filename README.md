# MTLR-for-Suvirval-
In the present work we have used a real database, from the survival package, to be able to test if there was an improvement in performance in the use of different survival models.
After making a conceptual discussion about four models, a parametric model, a semi-parametric model, a non-parametric model, and another within the category of machine learning, we have shown that the models have different performances. Possibly the answer to this improvement in performance lies in the use of censored data differently within the development of each model, as evidenced in the theory analysed in this paper.
We base the previous hypothesis on the fact that the model that has the best performance, measured by the C-index, is the multitask logistic regression (MTLR) model, which is essentially a collection of logistic regression models built at different time intervals. to determine the probability that the event of interest would occur during each interval. The results provided by the MTLR are similar to the CoxPH model without relying on the CoxPH assumption that the hazard function for the two subjects is constant over time. 

Esta obra está sujeta a una licencia de 
Reconocimiento-NoComercial-SinObraDerivada 
3.0 España de Creative Commons

