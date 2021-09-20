

library(MASS)
library(dplyr)
library(ICSNP)
library(tidyverse)
library(nlme)
library(clubSandwich)
##########################################################################################
###############################     2.1 Summary of data     ############################## 
##########################################################################################
#### 1. Import data
lead <- read.table("lead.full.txt", header = F)
colnames(lead) = c("id", "ind.age", "sex", "week", "blood", "trt")
head(lead)

#### 2. Visualization
# ID
interaction.plot(lead$week, lead$id, lead$blood, ylim=c(0,50),
                 xlab="Time (in weeks)", ylab="Blood Lead Levels", 
                 main="Time Plot of Blood Lead Levels", 
# trt
interaction.plot(lead$week, lead$trt, lead$blood, ylim=c(19,28),type = "b", pch = c(1:3),
                 xlab="Time (in weeks)", ylab="Blood Lead Levels", 
                 main="Time Plot of Blood Lead Levels for Each Treatment", 
                 col=c(1:3))
# gender
interaction.plot(lead$week, lead$sex, lead$blood, ylim=c(20,30),type = "b",pch = c(1:2),
                 xlab="Time (in weeks)", ylab="Blood Lead Levels", 
                 main="Time Plot of Blood Lead Levels of Each Gender", 
                 col=c(1:2))
# Add indicator 
for(i in 1:nrow(lead)){
  if(lead$trt[i] == 1){
    lead$p[i] <- 0
    lead$d[i] <- 0
  }else{
    lead$p[i] <- 1
    for (j in 1:nrow(lead)) {
      if(lead$trt[i] == 2){
        lead$d[i] <- 0
      }else{
        lead$d[i] <- 1
      }
    }
  }
}



############################################################################################
####################################     2.2 Model     ##################################### 
############################################################################################

# Fixed effect
fixed = blood ~ 1 + week + ind.age + ind.age:week + sex + sex:week + sex:ind.age + 
  sex:ind.age:week + p + p:week + p:ind.age + p:ind.age:week + p:sex + p:sex:week + 
  p:sex:ind.age + p:sex:ind.age:week + p:d + p:d:week + p:d:ind.age + p:d:ind.age:week + 
  p:d:sex + p:d:sex:week + p:d:sex:ind.age + p:d:sex:ind.age:week 
# Independent, where error variance does not change over weeks
fit.1<- lme(fixed = fixed, random = ~ week|id, data = lead, method = "ML",control = lmeControl(opt='optim'))
# Independent, where error variance changes over weeks,
fit.2 <- lme(fixed = fixed, random = ~ week|id, data = lead, weights = varIdent(form = ~ 1|week),
             method = "ML", control = lmeControl(opt='optim'))
# AR(1) correlation structure, where error variance does not change over weeks
fit.3 <- lme(fixed = fixed, random = ~ week|id, data = lead, correlation = corAR1(form = ~ 1|id), 
             method = "ML",control = lmeControl(opt='optim'))
# AR(1) correlation structure, where error variance changes over weeks
fit.4 <- lme(fixed = fixed, random = ~ week|id, data = lead, weights = varIdent(form = ~ 1|week),
             correlation = corAR1(form = ~ 1|id) , method = "ML",control = lmeControl(opt='optim'))
# Unstructured, where error variance does not change over weeks
lead$timefact <- as.numeric(factor(lead$week), labels = 1:5)
fit.5 <- lme(fixed = fixed, random = ~ week|id, data = lead, correlation = corSymm(form = ~ timefact|id), 
             method = "ML",control = lmeControl(opt='optim'))
# Unstructured, where error variance changes over weeks
fit.6 <- lme(fixed = fixed, random = ~ week|id, data = lead, correlation = corSymm(form = ~ timefact|id), 
             weights = varIdent(form = ~ 1|timefact), method = "ML",control = lmeControl(opt='optim'))


############################################################################################
################################     2.3 Model Comparison     ############################## 
############################################################################################

# Information Criteria
AIC(fit.1,fit.2,fit.3,fit.4,fit.5,fit.6)
BIC(fit.1,fit.2,fit.3,fit.4,fit.5,fit.6)

############################################################################################
#######################     2.4.1 Inference about Gender and Age      ###################### 
############################################################################################

#### (i) Does gender has any association with bloood lead level? Does age has any association with blood lead level? 
mod.best <- fit.1 
# Age
H0.age <- blood ~ 1 + week + sex + sex:week  + p + p:week +  p:sex + p:sex:week + 
  p:d + p:d:week + p:d:sex + p:d:sex:week
H0.mod.age <- lme(fixed = H0.age, random = ~ week|id, data = lead, method = "ML",
                  control = lmeControl(opt='optim'))
anova.lme(mod.best, H0.mod.age)
# Gender
H0.gender <- blood ~ 1 + week + ind.age + ind.age:week + p + p:week + p:ind.age + 
  p:ind.age:week + p:d + p:d:week + p:d:ind.age + p:d:ind.age:week
H0.mod.gender <-lme(fixed = H0.gender, random = ~ week|id, data = lead, method = "ML",
                    control = lmeControl(opt='optim'))
anova.lme(mod.best,H0.mod.gender)


############################################################################################
########     2.4.2 Mean Trends of Blood Lead Levels for All Treatments Groups      ######### 
############################################################################################

#### (ii) Based on your findings in (i), propose a smaller models, if possible. Based on the smaller model, 
#         are the mean trends of blood lead level the same for the three treatments?
reduced.mod <- H0.mod.gender
L <- rbind(c(0,0,0,0,1,0,0,0,0,0,0,0),c(0,0,0,0,0,1,0,0,0,0,0,0),
           c(0,0,0,0,0,0,1,0,0,0,0,0),c(0,0,0,0,0,0,0,1,0,0,0,0),
           c(0,0,0,0,0,0,0,0,1,0,0,0),c(0,0,0,0,0,0,0,0,0,1,0,0),
           c(0,0,0,0,0,0,0,0,0,0,1,0),c(0,0,0,0,0,0,0,0,0,0,0,1))
etahat <- as.matrix(fixed.effects(reduced.mod))
cc <- nrow(L)
df <- nrow(lead) - length(etahat)
# estimate and covariance matrix of L\beta
est <- L %*% etahat
V.robust <- vcovCR(reduced.mod,type = "CR0")
varmat <- L %*% V.robust %*% t(L)
# Wald test
Wald <- c( t(est) %*% solve(varmat) %*% (est) )
p.value <- pchisq(q = Wald, df = cc, lower.tail=FALSE)
data.frame(Wald, p.value)
# F-test
Fstat <- c( t(est) %*% solve(varmat) %*% (est) ) / cc
p.value <- pf(q = Fstat, df1 = cc, df2 = df, lower.tail=FALSE)
data.frame(Fstat, p.value)


# Plot for the population mean trends across all treatments and age
plot(c(0,2,4,6,8),mut.1, lty = 1, type = "b", pch = 19, col = 1, ylim = c(15,40), 
     xlab="Time in week", ylab = "Blood Lead Level", main = "Population Mean Trend")
lines(c(0,2,4,6,8),mut.2, lty = 2, type = "b", pch = 20, col = 2)
lines(c(0,2,4,6,8),mut.5, lty = 3, type = "b", pch = 21, col = 3)
lines(c(0,2,4,6,8),mut.6, lty = 4, type = "b", pch = 22, col = 4)
lines(c(0,2,4,6,8),mut.9, lty = 5, type = "b", pch = 23, col = 5)
lines(c(0,2,4,6,8),mut.10, lty = 6, type = "b", pch = 24, col = 6)
legend("topright",c("Placebo, age<24","Placebo, age>24","Low, age<24", "Low, age>24",
                    "High, age<24","High, age>24"),col = c(1:6), pch = c(19:24), lty = c(1:6),bty = "n")


############################################################################################
################################     2.4.3 Diagnostic      #################################
############################################################################################

#### (iv) Present some appropriate model diagnostics, and comment on the appropriateness 
#         of the model assumptions as best as you can.

### 1) Gender
# Male
male <- which(lead$ind.age==0)
res.male <- residuals(reduced.mod, level=1, type = "pearson")[male]
fitted.male <- predict(reduced.mod, level = 1)[male]
# Plot
plot(fitted.male, res.male,xlab="Fitted Value", ylab="Standardized Residual", main = "Male")
# QQ plot for Male
qqnorm(res.male, main = "QQ plot for Male")
qqline(res.male)

# Female
female <- which(lead$ind.age==1)
res.female <- residuals(reduced.mod, level=1, type = "pearson")[female]
fitted.female <- predict(reduced.mod, level = 1)[female]
# Plot
plot(fitted.female, res.female,xlab="Fitted Value", ylab="Standardized Residual", main = "Female")
# QQ plot for Female
qqnorm(res.female, main = "QQ plot for Female")
qqline(res.female)

# The entire data across gender
fitted <- predict(reduced.mod, level = 1)
plot(lead$blood,fitted, xlab = "Blood Lead Level",ylab = "Fitted Value", main="")


### 2) Treatment
# Placebo
placebo <- which(lead$p==0)
res.p <- residuals(reduced.mod, level=1, type = "pearson")[placebo]
fitted.p <- predict(reduced.mod, level = 1)[placebo]
# Plot
plot(fitted.p, res.p,xlab="Fitted Value", ylab="Standardized Residual", main = "Placebo")
# QQ plot for Placebo
qqnorm(res.p, main = "QQ plot for Placebo")
qqline(res.p)

# Low dose
Low <- which(lead$d==0&lead$p==1)
res.l <- residuals(reduced.mod, level=1, type = "pearson")[Low]
fitted.l <- predict(reduced.mod, level = 1)[Low]
# Plot
plot(fitted.l, res.l,xlab="Fitted Value", ylab="Standardized Residual", main = "Low Dose")
# QQ plot for Low dose
qqnorm(res.l,main = "QQ plot for Low Dose")
qqline(res.l)

# High dose
High <- which(lead$d==1&lead$p==1)
res.h <- residuals(reduced.mod, level=1, type = "pearson")[High]
fitted.h <- predict(reduced.mod, level = 1)[High]
# Plot
plot(fitted.h, res.h,xlab="Fitted Value", ylab="Standardized Residual", main = "High Dose")
# QQ plot for Male
qqnorm(res.h,main = "QQ plot for High Dose")
qqline(res.h)




############################################################################################
####################################     Appendix      #####################################
############################################################################################

#### (iii) Based on the smaller model in (ii), what is the mean trend of blood lead level of a patient who is
### (a) male with age < 24 receiving placebo, 
# Predict subject-level
P.male.less <- which(lead$p==0 & lead$ind.age==0 & lead$sex == 0)
P.Exp.male.less <- predict(reduced.mod, level=1)[P.male.less]
# Plot
w <- lead$week[P.male.less]
t <- c(0,2,4,6,8)
mut.1 <- etahat[1]+etahat[2]*t+etahat[3]*0 + etahat[4]*0*t
matplot(w, P.Exp.male.less, type = "b", lty = 2, col = "gray", pch=19, 
        xlab = "Time in week", ylab = "Blood Lead Level", 
        main = "Male with age < 24 receiving placebo")
lines(t, mut.1, type="b", lwd=2, pch=19)

### (b) male with age > 24 receiving placebo? Repeat this for the other two treatments, and also for females.

#################### Placebo #################### 
# Male with age > 24 receiving placebo
P.male.more <- which(lead$p==0 & lead$ind.age==1 & lead$sex == 0)
P.Exp.male.more <- predict(reduced.mod, level=1)[P.male.more]
# Plot
w <- lead$week[P.male.more]
t <- c(0,2,4,6,8)
mut.2 <- etahat[1]+etahat[2]*t+etahat[3]*1 + etahat[4]*1*t
matplot(w, P.Exp.male.more, type = "b", lty = 2, col = "gray", pch=19, 
        xlab = "Time in week", ylab = "Blood Lead Level", 
        main = "Male with age > 24 receiving placebo")
lines(t, mut.2, type="b", lwd=2, pch=19)

# Female with age < 24 receiving placebo
P.Female.less <- which(lead$p==0 & lead$ind.age==0 & lead$sex == 1)
P.Exp.female.less <- predict(reduced.mod, level=1)[P.Female.less]
# Plot
w <- lead$week[P.Female.less]
t <- c(0,2,4,6,8)
mut.3 <- etahat[1]+etahat[2]*t+etahat[3]*0 + etahat[4]*0*t
matplot(w, P.Exp.female.less, type = "b", lty = 2, col = "gray", pch=19, 
        xlab = "Time in week", ylab = "Blood Lead Level", 
        main = "Female with age < 24 receiving placebo")
lines(t, mut.3, type="b", lwd=2, pch=19)

# Female with age > 24 receiving placebo
P.Female.more <- which(lead$p==0 & lead$ind.age==1 & lead$sex == 1)
P.Exp.female.more <- predict(reduced.mod, level=1)[P.Female.more]
# Plot
w <- lead$week[P.Female.more]
t <- c(0,2,4,6,8)
mut.4 <- etahat[1]+etahat[2]*t+etahat[3]*1 + etahat[4]*1*t 
matplot(w, P.Exp.female.more, type = "b", lty = 2, col = "gray", pch=19, 
        xlab = "Time in week", ylab = "Blood Lead Level", 
        main = "Female with age > 24 receiving placebo")
lines(t, mut.4, type="b", lwd=2, pch=19)


#####################  Low Dose  ##################### 
# male with age < 24 receiving low dose
L.male.less <- which(lead$d==0 & lead$ind.age==0 & lead$sex == 0)
L.Exp.female.less <- predict(reduced.mod, level=1)[L.male.less]
# Plot
w <- lead$week[L.male.less]
t <- c(0,2,4,6,8)
mut.5 <- etahat[1]+etahat[2]*t+etahat[3]*0 + etahat[4]*0*t + etahat[5]+etahat[6]*t + etahat[7]*0 + etahat[8]*0*t
matplot(w, L.Exp.female.less, type = "b", lty = 2, col = "gray", pch=19, 
        xlab = "Time in week", ylab = "Blood Lead Level", 
        main = "Male with age < 24 receiving low dose")
lines(t, mut.5, type="b", lwd=2, pch=19)

# male with age > 24 receiving low dose
L.male.more <- which(lead$d==0 & lead$ind.age==1 & lead$sex == 0)
L.Exp.male.more <- predict(reduced.mod, level=1)[L.male.more]
# Plot
w <- lead$week[L.male.more]
t <- c(0,2,4,6,8)
mut.6 <- etahat[1]+etahat[2]*t+etahat[3]*1 + etahat[4]*1*t + etahat[5]+etahat[6]*t + etahat[7]*1 + etahat[8]*1*t
matplot(w, L.Exp.male.more, type = "b", lty = 2, col = "gray", pch=19, 
        xlab = "Time in week", ylab = "Blood Lead Level", 
        main = "Male with age > 24 receiving low dose")
lines(t, mut.6, type="b", lwd=2, pch=19)

# Female with age < 24 receiving low dose
L.female.less <- which(lead$d==0 & lead$ind.age==0 & lead$sex == 1)
L.Exp.female.less <- predict(reduced.mod, level=1)[L.female.less]
# Plot
w <- lead$week[L.female.less]
t <- c(0,2,4,6,8)
mut.7 <- etahat[1]+etahat[2]*t+etahat[3]*0 + etahat[4]*0*t + etahat[5]+etahat[6]*t + etahat[7]*0 + etahat[8]*0*t 
matplot(w, L.Exp.female.less, type = "b", lty = 2, col = "gray", pch=19, xlab = "Time in week", 
        ylab = "Blood Lead Level", main = "Female with age < 24 receiving low dose")
lines(t, mut.7, type="b", lwd=2, pch=19)

# Female with age > 24 receiving low dose
L.female.more <- which(lead$d==0 & lead$ind.age==1 & lead$sex == 1)
L.Exp.female.more <- predict(reduced.mod, level=1)[L.female.more]
# Plot
w <- lead$week[L.female.more]
t <- c(0,2,4,6,8)
mut.8 <- etahat[1]+etahat[2]*t+etahat[3]*1 + etahat[4]*1*t + etahat[5]+etahat[6]*t + etahat[7]*1 + etahat[8]*1*t 
matplot(w, L.Exp.female.more, type = "b", lty = 2, col = "gray", pch=19, xlab = "Time in week", 
        ylab = "Blood Lead Level", main = "Female with age > 24 receiving low dose")
lines(t, mut.8, type="b", lwd=2, pch=19)

#####################  High Dose  #################### 
# male with age < 24 receiving high dose
H.male.less <- which(lead$d==1 & lead$ind.age==0 & lead$sex == 0)
H.Exp.male.less <- predict(reduced.mod, level=1)[H.male.less]
# Plot
w <- lead$week[H.male.less]
t <- c(0,2,4,6,8)
mut.9 <- etahat[1]+etahat[2]*t+etahat[3]*0 + etahat[4]*0*t + etahat[5]+etahat[6]*t + etahat[7]*0 + 
  etahat[8]*0*t + etahat[9]+etahat[10]*t + etahat[11]*0 +etahat[12]*0*t
matplot(w, H.Exp.male.less, type = "b", lty = 2, col = "gray", pch=19, xlab = "Time in week", 
        ylab = "Blood Lead Level", main = "Male with age < 24 receiving High dose")
lines(t, mut.9, type="b", lwd=2, pch=19)

# male with age > 24 receiving high dose
H.male.more <- which(lead$d==1 & lead$ind.age==1 & lead$sex == 0)
H.Exp.male.more <- predict(reduced.mod, level=1)[H.male.more]
# Plot
w <- lead$week[H.male.more]
t <- c(0,2,4,6,8)
mut.10 <- etahat[1]+etahat[2]*t+etahat[3]*1 + etahat[4]*1*t + etahat[5]+etahat[6]*t + etahat[7]*1 + 
  etahat[8]*1*t + etahat[9]+etahat[10]*t + etahat[11]*1 +etahat[12]*1*t
matplot(w, H.Exp.male.more, type = "b", lty = 2, col = "gray", pch=19, xlab = "Time in week", 
        ylab = "Blood Lead Level", main = "Male with age > 24 receiving High dose")
lines(t, mut.10, type="b", lwd=2, pch=19)

# Female with age < 24 receiving high dose
H.female.less <- which(lead$d==1 & lead$ind.age==0 & lead$sex == 1)
H.Exp.female.less <- predict(reduced.mod, level=1)[H.female.less]
# Plot
w <- lead$week[H.female.less]
t <- c(0,2,4,6,8)
mut.11 <- etahat[1]+etahat[2]*t+etahat[3]*0 + etahat[4]*0*t + etahat[5]+etahat[6]*t + etahat[7]*0 + 
  etahat[8]*0*t + etahat[9]+etahat[10]*t + etahat[11]*0 +etahat[12]*0*t
matplot(w, H.Exp.female.less, type = "b", lty = 2, col = "gray", pch=19, xlab = "Time in week", 
        ylab = "Blood Lead Level", main = "Female with age < 24 receiving High dose")
lines(t, mut.11, type="b", lwd=2, pch=19)

# Female with age > 24 receiving high dose
H.female.more <- which(lead$d==1 & lead$ind.age==1 & lead$sex == 1)
H.Exp.female.more <- predict(reduced.mod, level=1)[H.female.more]
# Plot
w <- lead$week[H.female.more]
t <- c(0,2,4,6,8)
mut.12 <- etahat[1]+etahat[2]*t+etahat[3]*1 + etahat[4]*1*t + etahat[5]+etahat[6]*t + etahat[7]*1 + 
  etahat[8]*1*t + etahat[9]+etahat[10]*t + etahat[11]*1 +etahat[12]*1*t
matplot(w, H.Exp.female.more, type = "b", lty = 2, col = "gray", pch=19, xlab = "Time in week", 
        ylab = "Blood Lead Level", main = "Female with age > 24 receiving High dose")
lines(t, mut.12, type="b", lwd=2, pch=19)










