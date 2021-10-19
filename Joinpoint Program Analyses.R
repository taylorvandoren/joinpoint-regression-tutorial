### JOINPOINT REGRESSION TUTORIAL
### Guidelines for analyses in the Joinpoint Regression Program, built by the National Institutes of Health

# Taylor P. van Doren, ABD
# October 18, 2021

### IMPORTANT PRELUDE

# This file will go through the process of joinpoint regression analysis using the Joinpoint Regression Program
    # Joinpoint Trend Analysis is a statistical software built by the National Cancer Institute of the 
    # National Institutes of health, Division of Cancer Control& Population Science. The program is completely
    # open source and available for download at surveillance.cancer.gov/joinpoint. All you have to do is register 
    # for the software, and you will be sent a link with permission to download the program. It is perfect for 
    # researchers seeking to gain some insights into how rates change over time. 

# This file will introdue the data and get it ready to import into the joinpoint program, but the bulk of the 
    # analysis will not be performed within this R file. Most of the code here will be devoted to creating
    # visualizations of the data and analyses performed outside the file in the Joinpoint Regression Program. 

# There is another file dedicated to logistic joinpoint analyses within this Github Repository. Each of these 
    # methods are useful, but they are different approaches, so use the one that serves you best. 


### LOAD LIBRARIES

library(reshape2)
library(ggplot2)


### LOAD DATA

# This data is from the CDC National Center for Health Statistics National Vital Statistics System, 
    # the Age-Adjusted Death Rates for Selected Causes, Death Registration States, 1900-1932, and 
    # United States 1933-98.
    # link: https://www.cdc.gov/nchs/nvss/mortality/hist293.htm

mortdata <- read.csv("mortality data.csv")


### PLOT THE DATA

ggplot(mortdata, aes(year, asdr, color = cod)) +
  geom_point(size = 3.5, shape = 1) +
  geom_smooth() +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  tayloRswift::scale_color_taylor("lover")

# Looking at the initial plot will really help us develop some intuition about the kinds of results we 
    # might hope to see from the regression analyses. Since this regression method identifies points of 
    # significant change in rates over a time period, and there are some clear points here that we will
    # be looking out for when we run the regression.

# For example, it's clear that there was a major increase and then decrease of mortality rates from heart
    # disease during the 20th century, and it appears as if the turning point was somewhere during the 
    # 1950s. We should keep our eyes out for identified joinpoints in that decade. 

# The data are in the correct format for analyses in the joinpoint program, so we'll head over there to 
    # get the data analyzed. 

### SEE THE PDF OF THE INSTRUCTIONS ON HOW TO RUN THESE ANALYSES IN THE JOINPOINT REGRESSION SOFTWARE. 

# After analyses, we'll need to put together all the results and import them back to R so we can create 
    # some more appealing figures. 

# Import all model fits

modelfits <- read.csv("model fits.csv")

# modelfits has many columns of data, but they are all arranged to follow the basic format:
    # year
    # cause of death observed mortality rate (per 100,000) <-- original data used to fit models
    # cod.0: model fit with zero joinpoints
    # cod.1: model fit with one joinpoint
    # cod.2: model fit with two joinpoints
    # cod.3: model fit with three joinpoints

# Below, we will plot each cause of death separately so we can easily see all the model fits. 
    # The best-fit model as determined by the software will appear as a solid line; 
    # all other model fits appear as dashed lines. 

# ACCIDENTS
ggplot(modelfits, aes(x = year, y = accidents.obs)) +
  geom_point(size = 3, shape = 1, col = "darkgrey") +
  geom_line(aes(year, accidents.0), col = "#c91e63", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, accidents.1), col = "#9c27b0", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, accidents.2), col = "#ee5722", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, accidents.3), col = "#00bcd4", size = 1.5) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  ggtitle("Accidents")

# CANCER 
ggplot(modelfits, aes(x = year, y = cancer.obs)) +
  geom_point(size = 3, shape = 1, col = "darkgrey") +
  geom_line(aes(year, cancer.0), col = "#c91e63", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, cancer.1), col = "#9c27b0", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, cancer.2), col = "#ee5722", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, cancer.3), col = "#00bcd4", size = 1.5) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  ggtitle("Cancer")

# HEART DISEASE
ggplot(modelfits, aes(x = year, y = heart.obs)) +
  geom_point(size = 3, shape = 1, col = "darkgrey") +
  geom_line(aes(year, heart.0), col = "#c91e63", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, heart.1), col = "#9c27b0", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, heart.2), col = "#ee5722", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, heart.3), col = "#00bcd4", size = 1.5) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  ggtitle("Heart Disease")

# PNEUMONIA & INFLUENZA
ggplot(modelfits, aes(x = year, y = pi.obs)) +
  geom_point(size = 3, shape = 1, col = "darkgrey") +
  geom_line(aes(year, pi.0), col = "#c91e63", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, pi.1), col = "#9c27b0", size = 1.5) +
  geom_line(aes(year, pi.2), col = "#ee5722", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, pi.3), col = "#00bcd4", size = 1.1, linetype = "dashed") +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  ggtitle("Influenza & Pneumonia (P&I)")

# STROKE
ggplot(modelfits, aes(x = year, y = stroke.obs)) +
  geom_point(size = 3, shape = 1, col = "darkgrey") +
  geom_line(aes(year, stroke.0), col = "#c91e63", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, stroke.1), col = "#9c27b0", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, stroke.2), col = "#ee5722", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, stroke.3), col = "#00bcd4", size = 1.5) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  ggtitle("Stroke")

# TUBERCULOSIS
ggplot(modelfits, aes(x = year, y = tb.obs)) +
  geom_point(size = 3, shape = 1, col = "darkgrey") +
  geom_line(aes(year, tb.0), col = "#c91e63", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, tb.1), col = "#9c27b0", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, tb.2), col = "#ee5722", size = 1.1, linetype = "dashed") +
  geom_line(aes(year, tb.3), col = "#00bcd4", size = 1.5) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  ggtitle("Tuberculosis (TB)")

# Let's make a conglomerate plot to put all the best-fit models together with the fitted data
ggplot(modelfits) +
  geom_point(aes(year, accidents.obs), size = 3, shape = 1, color = "#5d6d7e") +
  geom_point(aes(year, cancer.obs), size = 3, shape = 1, color = "#5d6d7e") +
  geom_point(aes(year, heart.obs), size = 3, shape = 1, color = "#5d6d7e") +
  geom_point(aes(year, pi.obs), size = 3, shape = 1, color = "#5d6d7e") +
  geom_point(aes(year, stroke.obs), size = 3, shape = 1, color = "#5d6d7e") +
  geom_point(aes(year, tb.obs), size = 3, shape = 1, color = "#5d6d7e") +
  geom_line(aes(year, accidents.3), col = "#b8396b", size = 1.5) +
  geom_line(aes(year, cancer.3), col = "#ffd1d7", size = 1.5) +
  geom_line(aes(year, heart.3), col = "#fff5cc", size = 1.5) +
  geom_line(aes(year, pi.1), col = "#76bae0", size = 1.5) +
  geom_line(aes(year, stroke.3), col = "#b28f81", size = 1.5) +
  geom_line(aes(year, tb.3), col = "#54483e", size = 1.5) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Moratlity Rate (per 100,000)") +
  ggtitle("Major Causes of Death, 1900-1998")
  
