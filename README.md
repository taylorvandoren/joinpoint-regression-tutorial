# joinpoint-regression-tutorial
Joinpoint Regression method for University of Washington Population Dynamics Lab

## Welcome! 

This public Github repository is dedicated to a tutorial of **joinpoint regression modeling** in both R and in the [Joinpoint Regression Program](https://surveillance.cancer.gov/joinpoint/). This method is intuitive and ideal for demographic and epidemiologic analyses that requires knowing significant points of rate change in a time series. This statitsical modeling method can model *any type of rate change*, such as mortality, morbidity, fertility, prevalence, incidence, migration, etc. As long as it is a rate, it can model it and find where there are significant points of change. 

*All data, packages, and programs used in this repository are open source and free for you to use, suggest changes to, and learn from.*

The data used for this tutorial can be found at:
### [United States Vital Statistics, Age-Adjusted Death Rates for Leading Causes of Death, 1900-1998](https://www.cdc.gov/nchs/nvss/mortality/hist293.htm)

Here is a visualization of the mortality data used in this analysis:
![causes of death (accidents, cancer, heart disease, influenza & pneumonia, stroke, and tuberculosis) in the United States from 1900-1998](https://taylorvandoren.files.wordpress.com/2021/10/all-causes.png)

and we will be working our way towards fitting best-fit joinpoint models to the data:
![causes of death in the United States from 1900-1998 with best-fit joinpoint models visualized with data](https://taylorvandoren.files.wordpress.com/2021/10/best-fit-all-causes.png)

#### What you'll need

All you'll need you can find here in this repository:
- `mortality data.csv`
- `usa pop.csv`
- `model fits.csv`
- The ljr package (avalaible on CRAN to download)
- Other packages: ggplot2, reshape
