# joinpoint-regression-tutorial
Joinpoint Regression method for Population Dynamics Lab

## Welcome! 

This public Github repository is dedicated to a tutorial of **joinpoint regression modeling** in both R and in the [Joinpoint Regression Program](https://surveillance.cancer.gov/joinpoint/). This method is intuitive and ideal for demographic and epidemiologic analyses that requires knowing significant points of rate change in a time series. This statitsical modeling method can model *any type of rate change*, such as mortality, morbidity, fertility, prevalence, incidence, migration, etc. As long as it is a rate, it can model it and find where there are significant points of change. 

*All data, packages, and programs used in this repository are open source and free for you to use, suggest changes to, and learn from.*

The data used for this tutorial can be found at:
### [United States Vital Statistics, Age-Adjusted Death Rates for Leading Causes of Death, 1900-1998](https://www.cdc.gov/nchs/nvss/mortality/hist293.htm)

Here is a visualization of the mortality data used in this analysis:
![causes of death (accidents, cancer, heart disease, influenza & pneumonia, stroke, and tuberculosis) in the United States from 1900-1998](https://taylorvandoren.files.wordpress.com/2021/10/all-causes.png)

and we will be working our way towards fitting best-fit joinpoint models to the data:
![causes of death in the United States from 1900-1998 with best-fit joinpoint models visualized with data](https://taylorvandoren.files.wordpress.com/2021/10/best-fit-all-causes.png)

*One thing I must mention is that the above figures were made by calling a different [Github repository dedicated to color palettes of Taylor Swift albums](https://github.com/asteves/tayloRswift). These figures are in `lover`.*

## Analyses we'll do

I'll go through two ways to do joinpoint modeling: 
1. With the `ljr` (logistic joinpoint regression) package in R
   - `ljr` is powerful, but it only models logistic fits. That's okay! In the R script provided (Joinpoint Regression in R.R), I have written code to go through this step by step.
3. With the **Joinpoint Regression Program**, which is an open-source software that you can download from the link at the top of this page. 
   - This program, honestly, has so much more functionality than the `ljr` package, so even though it isn't in R, I have found that it's worth demonstrating anyway. I have provided R code (Joinpoint Program Analyses.R) to walk through the data visualization provided by the model output (and I have provided the model output in `model fits.csv`), but *most* of the tutorial will be accessible in a PDF where I walk through screenshots of the program.


## What you'll need

All you'll need you can find here in this repository:
- `mortality data.csv`
- `usa pop.csv`
- `model fits.csv`
- The ljr package (avalaible on CRAN to download)
- Other packages: ggplot2, reshape2, dplyr
