#Getting current work directory
getwd()

#changing the directory to the one that contains the dataset and loading the data into a variable.
setwd("M:\\")
dt = read.csv('Life Expectancy Data.csv')
head(dt)

#Installing and loading required library()
install.packages("dplyr")
library(readr)
library(dplyr)
library(tidyr)
library('leaps')


#Renaming the variables to rename the intial code name
names(dt) <- c("Country", "Country_Code", "Continent","Life_expectancy", "Access_to_electricity", "Adjusted_net_national_income",
                  "Adjusted_net_national_income_per_capita", "Children_0_to_14_newly_infected_with_HIV",
                  "Children_out_of_school_primary", "Educational_attainment_primary",
                  "Educational_attainment_Bachelors", "Mortality_rate_infant", "Primary_completion_rate",
                  "Literacy_rate", "Real_interest_rate", "Population_growth", "Population_density",
                  "Population_total", "Current_health_expenditure_per_capita", "Current_health_expenditure",
                  "Unemployment_total", "GDP_Growth", "GDP_per_capita", "Birth_rate",
                  "Renewable_energy_consumption", "Adults_15_to_49_newly_infected_HIV",
                  "People_using_safely_managed_drinking_water_services"," Poverty_headcount_ratio",
                  "Compulsory_education_duration")


#checking the dimension, structure and summary information of the dataset
dim(dt)
str(dt)
summary((dt1))

#We want to view the graphical illustration of the data, first we need to install and load ggplot
install.packages("ggplot2")
library(ggplot2)

#p <- dt %>% group_by(Continent) %>% ggplot(aes(x = Continent, y = Life_expectancy)) + geom_col()
#print(p)

#We plot a graph to check the relationship of children out of schools across the continent
pP<- dt %>% group_by(Continent) %>% ggplot(aes(x = Continent, y = Children_out_of_school_primary)) + geom_col()
print(pP)


#Removing Data with more than 80-% missing values and removing the categorical column
data1 <- dt[,c(-1,-2,-3,-10,-11,-14,-25,-28)]
str(data1)

#Checking collinearity before imputation to remove some variables
#Instaling and loading the ggcorrplot library
install.packages("ggcorrplot")
library(ggcorrplot)
install.packages("GGally")
library(GGally)

data1_col<-ggcorr(data1[-1], 
          label = T, 
          label_size = 2,
          label_round = 2,
          hjust = 1,
          size = 3, 
          color = "royalblue",
          layout.exp = 5,
          low = "green3", 
          mid = "gray95", 
          high = "darkorange",
          name = "Correlation")
print(data1_col)


#Removing Data with high colinearity
data1 <- data1[,c(-3,-5,-7,-10,-13)]
#We remove population total as it is a problem to our dataset
#data1$Population_total=as.numeric(data1$Population_total)
data1 <- data1[,c(-8)]

#Installing and loading MICE to compute imputation
install.packages('mice')
library(mice)

#Now we do the imputation
data1_imp1 <- mice(data1, seed = 23109)
print(data1_imp1)

#Checking the complete datasets is possible with the complete() function
#complete(imp,m) where m is the number of iterations
complete(data1_imp1)
complete(data1_imp1,2)

data1_imp1$imp

#usign stripplot and xyplot to check the patten of the imputed dataset 
stripplot(data1_imp1, pch = 20, cex = 1.2)
xyplot(data1_imp1, Adjusted_net_national_income_per_capita  ~ Unemployment_total | .imp, pch = 20, cex = 1.4)


#checking the model fit
model.fit <- with(data1_imp1, lm(Life_expectancy ~ Access_to_electricity + Adjusted_net_national_income_per_capita
                                 + Adjusted_net_national_income_per_capita + Children_out_of_school_primary 
                                 + Primary_completion_rate + Real_interest_rate + Population_density
                                 + Current_health_expenditure + Unemployment_total + GDP_Growth + GDP_per_capita + Birth_rate
                                 + Adults_15_to_49_newly_infected_HIV + People_using_safely_managed_drinking_water_services
                                 + Compulsory_education_duration))
summary(model.fit)
#If we want to see all the model fit
print(summary(model.fit), n = 75)

#we pool the model
pooled.model<-pool(model.fit)
summary(pooled.model)
pool.r.squared(model.fit)


#we import the imputed dataset ina variablem and derive a model with it
data1_complete <- complete(data1_imp1,5)
full_model = lm(Life_expectancy ~ ., data=data1_complete)
summary(full_model)

#checking the standard error of the full model
stdres_fullmodel <- rstandard(full_model)
print(stdres_fullmodel)

plot(full_model$fitted.values,stdres_fullmodel,pch=16,
     ylab="Standardized Residuals",xlab="fitted y",ylim=c(-3,3),main="Full model")
abline(h=0)
abline(h=2,lty=2)
abline(h=-2,lty=2)
qqnorm(stdres_fullmodel, ylab="Standardized Residuals",
       xlab="Normal Scores", main="QQ Plot for Full model" )
qqline(stdres_fullmodel)
plot(full_model)
AIC(full_model)
BIC(full_model)

#Checking for COLLINEARITY
#Using graphical method
full_model_corr <- ggcorr(data1_complete[-1], 
       label = T, 
       label_size = 2,
       label_round = 2,
       hjust = 1,
       size = 3, 
       color = "royalblue",
       layout.exp = 5,
       low = "green3", 
       mid = "gray95", 
       high = "darkorange",
       name = "Correlation")
print(full_model_corr)

#Checking for Collinearity again, using corrplot
library(corrplot)
m <- cor(data1_complete[-1])
corrplot(m, tl.pos='lt',tl.cex = 0.55,tl.offset = 0.5, tl.srt = 15,tl.col = "darkblue", method = "number")

#Another Method
#install.packages("olsrr")
#library(olsrr)
#ols_vif_tol(full_model)

#loading the new reduced dataset into a variable
data1_adjusted <- data1_complete[,c(-5,-10,-14)]
model_adjusted = lm(Life_expectancy ~ ., data=data1_adjusted)
summary(model_adjusted)


#CHECKING FOR BEST MODEL using Stepwise Regression
#using forward stepwise
install.packages("olsrr")
library(olsrr) #loading the library
forward_step <-ols_step_forward_p(model_adjusted, details = TRUE)
print(forward_step)
#plot(forward_step)
#after this regression, the program has selected 10 variables that explained the response one

#backward stepwise
backward_step <- ols_step_backward_p(model_adjusted, details = TRUE)
print(backward_step)
#plot(backward_step)
#this removed one variable, leaving the 10 variables which is the same as the fordward stepwise

#stepwise_both_regression
both_step <- ols_step_both_p(model_adjusted, details = TRUE)
print(both_step)
#plot(both_step)
# This one returned 8 variables

#creating a model with the selected variables, and picking the best between the models
alt_model_1 <- lm(Life_expectancy ~ Birth_rate  + GDP_per_capita + Access_to_electricity + Adults_15_to_49_newly_infected_HIV
                  + Population_density  + Current_health_expenditure + Unemployment_total
                  + Real_interest_rate + Children_out_of_school_primary + Adjusted_net_national_income_per_capita, data = data1_adjusted)
summary(alt_model_1)
#checking the AIC and BIC
AIC(alt_model_1)
BIC(alt_model_1)

alt_model_2 <- lm(Life_expectancy ~ Birth_rate  + GDP_per_capita + Access_to_electricity + Adults_15_to_49_newly_infected_HIV
                  + Population_density  + Current_health_expenditure + Unemployment_total
                  + Real_interest_rate, data = data1_adjusted)
summary(alt_model_2)
AIC(alt_model_2)
BIC(alt_model_2)


#Conducting an Anova test to pick the best model between the full model and the reduced model
anova(full_model,alt_model_2)
#we fail to reject H0: the Full model is better


#4

install.packages("tibble")
library(tibble)
data_con<-cbind(dt[3], data1_adjusted)
str(data_con)
attach(data_con)

#PREDICTION
life_pred <- predict(alt_model_2, data_con)
full_model_1<- lm(Life_expectancy~ . , data = data_con)
summary(full_model_1)
summary(life_pred)

install.packages('MLmetrics')
library(MLmetrics)
# data.frame(Method = c("MSE","RMSE"), 
#            Error.Value = c(MSE(life_pred, data_con$Life_expectancy),
#                            RMSE(life_pred, data_con$Life_expectancy)))
range(data_con$Life_expectancy)

#If we take a look the Error Value from every methods, 
#the error seems small compared to the range of the Life_Expectancy as the Dependent Variable. 
#Therefore we can assume that the predicted values will not so far from the actual values.

#Under one-way ANOVA,we want to investigate whether there are differences in the average Life expentancy between the  different continents.
#Before we employ the one-way ANOVA model,
#we should check for some summary statistics(e.g check the groupmeans),investigate the data set using graphical representations of data.
group.means<-tapply(Life_expectancy,Continent,mean) 
group.means
boxplot(Life_expectancy~Continent,main='Comparing the life expectancy accross the continents', xlab='Continent',col="lightgray",ylab="Life_expectancy",)
#Create a density plot showing Life expentancy by continent
ggplot(data_con, aes(x=Life_expectancy)) + geom_density (aes(fill=Continent), size=1) + facet_wrap(~Continent)+
  theme_classic() + ggtitle("Life Expectancy Across Continents")

#We can confirm that the predicted values and the actual values are in the same range.
#Therefore we can conclude our predictions are plausible.




#The F-statistic value and the p-value can be used to draw conclusions in relation
#to the null hypothesis of ???no differences between the group means???.
anova1way<-aov(Life_expectancy~as.factor(Continent),data = data_con) 
summary(anova1way)

#The values we need to check from this table are the F-value and the p-value in the last column of the table
#(Pr(>F)). We see, that we are able to reject H0 at the all significance level.


#Multiple Comparison
cat("Bonferroni post-hoc test","\n")

###Bonferroni post-hoc test
pairwise.t.test(Life_expectancy, Continent, p.adj = "bonferroni")

## p-value adjustment method: bonferroni
cat("\n","Tukey post-hoc test","\n")

## Tukey post-hoc test
tukey.continent<-TukeyHSD(anova1way)
print(tukey.continent)

#From the R extract output above (looking at columns ???diff??? and ???p adj???) we see that  Asia-Africa, Australia/Oceania-Africa
#Europe - Africa, North America - Africa, South America - Africa have significant differences in Life Expectancy from the other continents. 
#We can also visualise the confidence interval derived the Tukey post-hoc test as follows:

plot(tukey.continent)




#The normality assumption can be checked using a qq-plot of the residuals. 
#A boxplot of the residuals can also be used to check the normality assumption 
#but also to asses whether the variance in the groups is the same.
install.packages("MLmetrics")                   
library(MLmetrics)
newDatasetQ4$residuals1<-anova1way$residuals
par(mfrow=c(1,2))
hist(newDatasetQ4$residuals1, main="Standardised residuals-histogram",xlab="Standardised residuals")
#Most of the residuals seems distributed on the center, 
#indicates they are distributed normally.

qqnorm(newDatasetQ4$residuals1,pch=19)
qqline(newDatasetQ4$residuals1)
#Most of the residuals gathered on the center line, 
#indicates they are distributed normally




#Moreover, a Shapiro test can be used to test the hypothesis that the residuals are normally distributed,
#using the R built in function shapiro.test()

shapiro.test(newDatasetQ4$residuals1)

#Notice that under the Shapiro test, H0 : The data is normally distributed. For Life expextancy,
#we fail to reject the null hypothesis.
#Based on Shapiro-Wilk normality test, the p-value > 0.05 implying 
#that the distribution of the data are significantly different from normal distribution.
#Therefore, we don't need to do some adjustment to data.

#A  Levene???s test can be used to test the hypothesis that the variance of the residuals
#between groups is the same
install.packages("car")
library(car)
leveneTest(Life_expectancy~factor(newDatasetQ4$Continent))

#Thanks to what we see with the output, we can notice a variance equality between
#the various factor levels


#We can conclude that The linear model seems fit to predict Life_expectancy based on 
#the Adj. R-Squared value, Error Value and pass Assumption Check as Shapiro test, 
#Levene's test and Linearity test.
#However, the Normality and Homocedasticity give the expected result.  give the expected result. 
#Even when we look at the visualization the residuals plot seems following Normal Distribution 
# Homocedasticity principle, and the statistic test also.

#The Linear Model can be used to explain the linear correlation between Life_expectancy and the selected independent variables. 
#However, since this model is highly sensitive to outliers , 
#it is highly recommended to see the outliers pattern 
#if you still wish to use this model on the new set of Life_expectancy.


