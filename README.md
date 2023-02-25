# LifeExpectancy2020
**Objective:**
The goal is to determine the predictors that contribute to the response variable (Life Expectancy), check for collinearity amongst the predictors, and to propose a model which explains our response variable in the world for the year 2020. Then use an appropriate experimental design to study the average life expectancy across the continents.

**Introduction**
Life expectancy at birth is the average number of years a person is expected to live. It is one of the most commonly used statistical measures in assessing a country's or region's level of development and human development index.
The dataset for this project was collected from Moodle which was derived from a primary World Bank database for development data from officially recognized international sources. The dataset is composed of 29 variables and 217 observations.
There are 25 variables which are predictors, 1 response variable which is Life expectancy at birth, and the remaining are categorical variables which are the countries, country codes, and continents where the data were taken from. The names of the variables in the datasets are written in code but for simplicity, we would be remaining them to their actual meaning.
We want to check the relationship of one of the variables, children out of primary school. From the figure below, the ratio of children that are not in primary education is very high in Africa, compared to other continents, with Asia being the next and South America being the least.
 
Figure 1 Relationship between variables
<img width="475" alt="image" src="https://user-images.githubusercontent.com/125979657/221373679-8e4f92a6-1a03-4f00-bd51-836a2f840b2c.png">

**Conclusion**
To conclude, deleting the predictor variables was not an appropriate choice to deal with missing values as all information in the variables would be lost. However, the multiple imputation method was used as it takes care of variability and make estimators unbiased.
In the presence of collinearity, three more variables were removed after imputation as there was still a presence of collinearity between them. For better understanding of life expectancy and the factors that affect it, we used the Full model and compared with the reduced model by performing an Analysis of Variance (ANOVA) which made us choose the Full model because the p-value is lower than all significant levels.
An experimental design (One-way ANOVA, F-statistics test and p-values) was carried out to study the differences of average life expectancies across the continents and we found out that Asia-Africa, Australia/Oceania-Africa, Europe - Africa, North America - Africa, and South America - Africa have significant differences in Life Expectancy from the other continents
