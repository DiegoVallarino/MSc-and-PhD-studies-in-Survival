# Libraries

library(survival)
library(KMsurv)
library(survMisc)
library(survminer)
library(ggfortify)
library(flexsurv)
library(knitr)
library(readxl)
library(ggplot2)
library(caret)
library(car)
library(MASS)
library(psych)
library(agricolae)
library(mixlm)
library(readxl)
library(cluster)
library(factoextra)
library(FactoMineR)
library (performance)
library(vcvComp)
library(dplyr)
library(MTLR)
library(risksetROC)
library(mstate)
library(cmprsk)
library(lattice)
library(nlme)
library(JM)
library(ranger)
library(VGAM)
library(lmtest)
library(censReg)
library(SurvMetrics)
library(scoring)
library(pec)

 
# Descritive

head(veteran)
str(veteran)
describeBy(veteran, veteran$celltype)
describeBy(veteran, veteran$trt)
describeBy(veteran, veteran$prior)
describeBy(veteran, veteran$age)
boxplot(veteran$celltype, veteran$age)
boxplot(veteran$age, veteran$karno) 
any(is.na(veteran))
```

# Train & Test data

set.seed(123)
data.train <- sample_frac(veteran, 0.7)
train_index <- as.numeric(rownames(data.train))
data.test <- veteran [-train_index, ]


# Primeros analisis

survdiff(Surv(time, status) ~ trt, data = data.train)
survdiff(Surv(time, status) ~ celltype, data = data.train)
survdiff(Surv(time, status) ~ prior + status, data = data.train)


# Relevancia de las variables a utilizar usando XGBoost

require(xgboost)
require(Matrix)
require(data.table)
df <- data.table(data.train, keep.rownames = FALSE)
sparse_matrix <- sparse.model.matrix(status~.-1, data = data.train)
head(sparse_matrix)
output_vector = df[,status] 
# desarrollo el modelo de relevancia
bst <- xgboost(data = sparse_matrix, label = output_vector, max.depth = 4, eta = 1, nthread = 2, nrounds = 10,objective = "binary:logistic")
# Medimos los la importancia de la variables.
importance <- xgb.importance(feature_names = sparse_matrix@Dimnames[[2]], model = bst)
head(importance)
# Mejora en la interpretabilidad de la tabla de datos de importancia de características
importanceRaw <- xgb.importance(feature_names = sparse_matrix@Dimnames[[2]], model = bst, data = sparse_matrix, label = output_vector)
importanceClean <- importanceRaw[,`:=`(Cover=NULL, Frequency=NULL)]
head(importanceClean)
xgb.plot.importance(importance_matrix = importanceRaw)

# Modelo de Tobit - parametric survival model


surv_obj = Surv(data.test$time, data.test$status)
fit2 <- survreg(Surv(time, status) ~ karno + age + trt, data=data.train)
predictfit2<-predict(fit2, data.test)
metrics_fit2<-Cindex(surv_obj, predicted = predictfit2)
summary(fit2)

# Kaplan-Meier Model - non parametric survival model

fit3<-survfit(Surv(time, status) ~ 1, data = data.train)
dis_timefit3 = fit3$time
med_indexfit3 = median(1:length(dis_timefit3))
predictfit3<-predictSurvProb(fit3, data.test, dis_timefit3)
metrics_fit3 = Cindex(surv_obj, predicted = predictfit3[, med_indexfit3])
ggsurvplot(fit3, data = veteran, pval = TRUE)
print(fit3, print.rmean=TRUE)
summary(fit3, times=c(20, 50, 100, 350))

# Cox models - semi parametric survival model


fit4 <- coxph(Surv(time, status) ~ ., data=data.train, x = TRUE)
shapiro.test(fit4$residuals)
anova(fit4)
dis_timefit4 = fit3$time 
med_indexfit4 = median(1:length(dis_timefit4))
predictfit4<-predictSurvProb(fit4, data.test, dis_timefit4)
metrics_fit4 = Cindex(surv_obj, predicted = predictfit4[, med_indexfit4])
summary(fit4)
ggforest(fit4)
test_cox<-cox.zph(fit4)
ggcoxzph(test_cox)


# MTLR Model - machine learning model

fit7 <- mtlr(Surv(time, status)~., data = data.train, nintervals = 9)
dis_timefit7 = fit7$time_points
med_indexfit7 = median(1:length(dis_timefit7))
predictfit7<-predict(fit7, data.test, type = "mean_time")
metrics_fit7 = Cindex(surv_obj, predicted = predictfit7)
fit7


# Cantidad de observaciones censuradas a la derecha

table(fit3$n.censor)
fit2$y
fit4$y
fit7$response


# Conclusion

metrics_fit2
metrics_fit3
metrics_fit4
metrics_fit7
data_CI = data.frame(Cindex = c(metrics_fit2, metrics_fit3, metrics_fit4, metrics_fit7),
                     Model = c(rep('Tobit', 1), rep('KM', 1),rep('Cox', 1),rep('MTLR', 1)))
ggplot(data_CI, aes(x = Model, y = Cindex)) + geom_boxplot()
ggplot(data_CI, aes(x = Model, y = Cindex)) + geom_col()
ggplot(data_CI, aes(x = Model, y = Cindex)) + geom_point()
