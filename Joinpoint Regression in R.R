### JOINPOINT ANALYSES IN R

# Taylor P. van Doren
# October 21, 2021

### INTRODUCTION ----

# This file goes through the analytical procedure and data visualization of
# joinpoint regression all in R.
# There is a dedicated Joinpoint Regression Program that you can use to run
# the same analyses and was built
# specifically for this regression method, and that procedure has been
# outlined in another file in this
# Github repository using the exact same data that we will use in this file.

# We will only need one package for this regression method: ljr
# "ljr" stands for logistic joinpoint regression.
# This means that these results are fit in a logistic model,
# but we could absolutely fit the model in the dedicated
# Joinpoint Regression Program without this logistic transformation.
# We could also theoretically transform the results of this analysis in R
# out of the logistic form, but we won't do that.

### JOINPOINT REGRESSION BASICS ----

# The general joinpoint regression equation is:
# y(fit) = Beta0 + Beta1*x + delta1(x - tau1) + ... + Deltak(x - tauk) + error
#     y(fit) = fitted y values
#     Beta0 = y intercept
#     Beta1 = slope estimate before any joinpoints
#     delta1 = slope estimate after a joinpoint or between two joinpoints
#     tauk = the location of the estimated joinpoint

# Remember, however, this package uses a logistic transformation on our data to
# fit these models, so instead of fitting
# y = xb, we are rather fitting ln(y) = xb.

### DATA SETUP ----

# First, let's load our libraries and the data we'll need.

library(ljr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(tidyr)
library(ggsci)
# (that's it!)
# yearly mortality rate for major causes of death in US 1990-1998
mortdata <- read.csv("mortality data.csv")
# yearly US population size 1900-1998
pop <- read.csv("usa pop.csv")

# the max age-specific death rate in this data is 612.4 deaths per 100,000
# that's P&I during the 1918 influenza pandemic!
summary(mortdata)

# Major causes of death we're looking at:
#   1. Accidents
#   2. Cancer
#   3. Heart disease
#   4. Influenza & Pneumonia (P&I)
#   5. Stroke
#   6. Tuberculosis (TB)

# Let's plot the data first to see what kinds of patterns we can identify
# without doing any modeling yet.
# (can you find the dot for the 1918 influenza pandemic?)

ggplot(mortdata, aes(year, asdr, color = cod)) +
  geom_point(size = 2, shape = 16, alpha = 0.6) +
  geom_smooth(alpha = 0) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  scale_color_jco()

# And the same figure again with a log transformation
# (so we can better prepare for the following logistic analyses)

mortdata$asdrlog <- log(mortdata$asdr)
ggplot(mortdata, aes(year, asdr, color = cod)) +
  geom_point(size = 2, shape = 16, alpha = 0.6) +
  geom_smooth(alpha = 0) +
  theme_classic() +
  xlab("Year") +
  ylab("Age-Adjusted Death Rate (per 100,000)") +
  scale_color_jco() +
  scale_y_log10()

# Looking at this figure, we will be able to make some pretty good educated
# guesses about where we might find joinpoints.
# For example, TB declined SO MUCH during the 20th century!
# Where did it decline, exactly? If you want to know a lot more
# detail about that, check out Noymer (2009)
# "Testing the influenza-tuberculosis selective mortality hypothesis with
# Union Army data", Noymer (2011)
# "The 1918 influenza pandemic hastened the decline of tuberculosis
# in the United States: An age, period, cohort analysis", and
# van Doren & Sattenspiel (2021) "The 1918 influenza pandemic did not
# accelerate tuberculosis mortality decline in early-20th century
# Newfoundland: Investigating historical and social explanations."

# Aside from that, it looks like there was a major decline in P&I before
# mid-century, some decline in accidents in the 1970s,
# and a big increase and then decrease through mid-century in heart disease,
# a really fascinating epidemiological phenomenon
# that was described by Gage (2005)
# "Are modern environments really bad for us?: Revisiting the demographic
# and epidemiologic transitions."

# I like to start with these initial visualizations in order to get a sense
# of where we are going before we start going
# there. It helps develop intuition about statistical modeling and helps us
# really check to see if we understand the results we get.

# Right now, mortdata is organized in a long format,
# but for this analysis it will be better to have it in wide format.

# As we will see in a few moments, the ljr() functions do not take mortality
# rates as arguments! What we will instead input as arguments are the number
# of deaths and the population size. Now, we need to back-calculate the
# number of deaths from each cause in each year using the yearly population
# of the US to do so.

mdw <- mortdata %>%
  select(year, cod, r = asdr) %>%
  # combine the pop data with the mortality rate data
  left_join(pop, by = "year") %>%
  # back calculate number of deaths
  mutate(n = r / 100000 * pop) %>%
  # rename cod to more convenient names
  mutate(cod = case_when(
    cod == "Accidents" ~ "accidents",
    cod == "Cancer" ~ "cancer",
    cod == "Heart Disease" ~ "heart",
    cod == "Influenza and Pneumonia" ~ "pi",
    cod == "Stroke" ~ "stroke",
    cod == "Tuberculosis" ~ "tb"
  )) %>%
  # shape to wide
  pivot_wider(
    names_from = "cod", values_from = c("r", "n"),
    names_glue = "{cod}.{.value}")

# Let's plot a couple real quick to make sure we have what we need

plot(mdw$pi.n)
plot(mdw$heart.n)
plot(mdw$tb.n)

### LOGISTIC JOINPOINT MODELING ----

# Fitting the data, finding the joinpoints.

# the 'ljr' package contains a number of built-in functions, but we will be
# working with only three:
#   1. ljr0() : fits zero joinpoints - just a straight line!
#   2. ljr1() : fits a single joinpoint at the most significant point of
#               change over the time period
#   3. ljrk() : fits as many joinpoints as you want!
# WARNING: ANYTHING OVER 3 CAN TAKE A LONG TIME
# And obviously: be careful about overfitting your model!

# Let's run a few of these models to see what the outputs look like.
# One of the great things about these models is that the output is
# very short and very intuitive. They also print automatically!


# We'll use P&I first
# arguments: number of deaths, population size
# (denominator of mortality rate), time
# the output of this fit is super straightforward:
# we have a y-intercept of 46.75... and a slope of -0.027...
# you can index these values easily as well
fit.1 <- ljr0(mdw$pi.n, mdw$pop, mdw$year)

# arguments: number of deaths, population size, time
# summ parameter automatically print summary table
# now, we have a y-int of -15.61... and some other things!
# g0 is the slope of the line before any joinpoints are identified.
# g1 max(t-tau1,0)
# is the slope of the line after the joinpoint is identified.
# we also have our first tau (joinpoint) estimate: 1918!
fit.2 <- ljr1(mdw$pi.n, mdw$pop, mdw$year, summ = TRUE)

# arguments: number of joinpoints to find (k),
# number of deaths, population size, time
# y-intercept: -27.9...
# g0: slope from 1900-1918: 0.0115
# g1 max(t-tau1,0), slope from 1919-1956: 0.0337
# g2 max(t-tau2,0), slope from 1957-1998: -0.058
# what this means is that after 1956 P&I deaths decreased a lot!
fit.3 <- ljrk(2, mdw$pi.n, mdw$pop, mdw$year)

# arguments: number of joinpoints to find (k),
# number of deaths, population size, time
# If you ran this model, you likely noticed how much SLOWER it was.
# You can ask the model to fit as many joinpoints as your heart desires.
# But you have to think about whether this is a smart thing to do or
# not, and what it would mean to fit all those points. It would end up
# being likely pretty meaningless. So take a look at this output and see
# if you can interpret it.
fit.4 <- ljrk(3, mdw$pi.n, mdw$pop, mdw$year)



# Since we want to be able to do all of this more quickly without writing four
# different models for every cause of death,
# let's write a function instead that will do everything we want,
# including extracting those tau estimates
# so we can easily index them for data visualization

jp.calc <- function(exp.deaths, pop, time) {

  # calculate the joinpoint estimates for each cause of death, 0-3
  x0 <- ljr0(exp.deaths, pop, time)
  x1 <- ljr1(exp.deaths, pop, time, summ = T)
  x2 <- ljrk(2, exp.deaths, pop, time)
  x3 <- ljrk(3, exp.deaths, pop, time)

  # print the list of coefficients (slopes between joinpoints)
  print(list(x0$Coef, x1$Coef, x2$Coef, x3$Coef))

  # print the list of joinpoints for the 1, 2, 3 joinpoint models
  print(list(x1$Joinpoint, x2$Joinpoints, x3$Joinpoints))

}

# Fit all the models!

accidents.calc <- jp.calc(mdw$accidents.n, mdw$pop, mdw$year)
cancer.calc <- jp.calc(mdw$cancer.n, mdw$pop, mdw$year)
heart.calc <- jp.calc(mdw$heart.n, mdw$pop, mdw$year)
pi.calc <- jp.calc(mdw$pi.n, mdw$pop, mdw$year)
stroke.calc <- jp.calc(mdw$stroke.n, mdw$pop, mdw$year)
tb.calc <- jp.calc(mdw$tb.n, mdw$pop, mdw$year)

# run them all and then make yourself some coffee
# they'll be done when you get back



### MAKING SENSE OF THE MODEL FITS ----

# Remember that each model itself prints its output automatically,
# so by running the function that we wrote
# with each of the models inside of it,
# every time you run the function you should get the four model
# outputs individually, along with the slope estimates for each of the
# segments of the fitted model and, finally, the indexable tau (joinpoint)
# values. This is what we will use to visualize our data.

# when I simply print the name of the object,
# what comes up is the list of joinpoint estimates.
heart.calc
# you can index these easily:
heart.calc[[1]]
heart.calc[[2]]
heart.calc[[3]]


# Let's make tables of all the joinpoint estimates
death.cause <- c("accidents", "cancer", "heart disease", "P&I", "stroke", "TB")
one.joinpoint <- data.frame(
  accidents.calc[[1]], cancer.calc[[1]], heart.calc[[1]], pi.calc[[1]],
  stroke.calc[[1]], tb.calc[[1]])
colnames(one.joinpoint) <- death.cause
two.joinpoints <- data.frame(
  accidents.calc[[2]], cancer.calc[[2]], heart.calc[[2]], pi.calc[[2]],
  stroke.calc[[2]], tb.calc[[2]])
colnames(two.joinpoints) <- death.cause
three.joinpoints <- data.frame(
  accidents.calc[[3]], cancer.calc[[3]], heart.calc[[3]], pi.calc[[3]],
  stroke.calc[[3]], tb.calc[[3]])
colnames(three.joinpoints) <- death.cause

jp.summary <- list(one.joinpoint, two.joinpoints, three.joinpoints)
jp.summary

# Time to visualize what we have here
# Before we do that, it's important to remember that although we INPUT the data
# as number of deaths and population size, the model used that information
# and fit them as though they were rates. So, we'll need to PLOT the log
# transformed mortality rates, and then visualize the joinpoint estimates

accidents.plot <- ggplot(mdw, aes(year, accidents.r)) +
  geom_point(shape = 21, size = 3.5, color = "black", fill = "darkgrey", alpha = 0.6) +
  theme_classic() +
  xlab("Year") +
  ylab("Accident Mortality") +
  scale_y_log10()

# Now we'll add vertical lines where the models have estimated there are
# significant changes in mortality rates

# One-joinpoint model:
accidents.plot +
  geom_vline(xintercept = accidents.calc[[1]], size = 1.2, color = "#5C6BC0")

# Two-joinpoint model
accidents.plot +
  geom_vline(xintercept = accidents.calc[[2]], size = 1.2, color = "#26C6DA")

# Three-joinpoint model
accidents.plot +
  geom_vline(xintercept = accidents.calc[[3]], size = 1.2, color = "#FFA726")

# One of the things that you might have noticed by now, if not by looking at the
# list output of the jp.calc() runs, but certainly by visualizing the data
# and the estimated points of change, the joinpoint estimates are
# not necessarily the same from each fit to the next. As seen above for the
# accidents mortality data, there is always a joinpoint estimated somewhere
# around 1970, but it is never the exact same x value every single time.
# This is because the joinpoint estimates are highly dependent on where the
# preceding point is estimated, if there is a preceding point.

# As we can see by the list output, if there is only one joinpoint, the most
# significant point of change is in 1968. But when there is a joinpoint
# estimated BEFORE that time, then the estimate changes to 1971.
# When TWO points are estimated before that, then the estimate is 1967.
accidents.calc


# We can visualize them all together on the same plot
accidents.plot +
  geom_vline(xintercept = accidents.calc[[1]], size = 1.2, color = "#5C6BC0") +
  geom_vline(xintercept = accidents.calc[[2]], size = 1.2, color = "#26C6DA") +
  geom_vline(xintercept = accidents.calc[[3]], size = 1.2, color = "#FFA726") +
  ggtitle("Accidents")


# Let's finish by visualizing the rest of our model fits.

# CANCER

cancer.plot <- ggplot(mdw, aes(year, cancer.r)) +
  geom_point(shape = 21, size = 3.5, color = "black", fill = "darkgrey") +
  theme_classic() +
  xlab("Year") +
  ylab("Cancer Mortality") +
  scale_y_log10()

cancer.plot +
  geom_vline(xintercept = cancer.calc[[1]], size = 1.2, color = "#5C6BC0") +
  geom_vline(xintercept = cancer.calc[[2]], size = 1.2, color = "#26C6DA")  +
  geom_vline(xintercept = cancer.calc[[3]], size = 1.2, color = "#FFA726") +
  ggtitle("Cancer")

# in the cancer plot, you can't even see the single joinpoint estimate because
# it is so close to the other estimates of the other models!
cancer.calc

# HEART DISEASE

heart.plot <- ggplot(mdw, aes(year, heart.r)) +
  geom_point(shape = 21, size = 3.5, color = "black", fill = "darkgrey") +
  theme_classic() +
  xlab("Year") +
  ylab("Heart Disease Mortality") +
  scale_y_log10()

heart.plot +
  geom_vline(xintercept = heart.calc[[1]], size = 1.2, color = "#5c6bc0") +
  geom_vline(xintercept = heart.calc[[2]], size = 1.2, color = "#26c6da") +
  geom_vline(xintercept = heart.calc[[3]], size = 1.2, color = "#ffa726") +
  ggtitle("Heart Disease")

# INFLUENZA & PNEUMONIA

pi.plot <- ggplot(mdw, aes(year, pi.r)) +
  geom_point(shape = 21, size = 3.5, color = "black", fill = "darkgrey") +
  theme_classic() +
  xlab("Year") +
  ylab("Influenza & Pneumonia Mortality") +
  scale_y_log10()

pi.plot +
  geom_vline(xintercept = pi.calc[[1]], size = 1.2, color = "#5c6bc0") +
  geom_vline(xintercept = pi.calc[[2]], size = 1.2, color = "#26c6da") +
  geom_vline(xintercept = pi.calc[[3]], size = 1.2, color = "#ffa726") +
  ggtitle("Influenza & Pneumonia")

# STROKE

stroke.plot <- ggplot(mdw, aes(year, stroke.r)) +
  geom_point(shape = 21, size = 3.5, color = "black", fill = "darkgrey") +
  theme_classic() +
  xlab("Year") +
  ylab("Stroke Mortality") +
  scale_y_log10()

stroke.plot +
  geom_vline(xintercept = stroke.calc[[1]], size = 1.2, color = "#5c6bc0") +
  geom_vline(xintercept = stroke.calc[[2]], size = 1.2, color = "#26c6da") +
  geom_vline(xintercept = stroke.calc[[3]], size = 1.2, color = "#ffa726") +
  ggtitle("Stroke")

# TUBERCULOSIS

tb.plot <- ggplot(mdw, aes(year, tb.r)) +
  geom_point(shape = 21, size = 3.5, color = "black", fill = "darkgrey") +
  theme_classic() +
  xlab("Year") +
  ylab("Tuberculosis Mortality") +
  scale_y_log10()

tb.plot +
  geom_vline(xintercept = tb.calc[[1]], size = 1.2, color = "#5c6bc0") +
  geom_vline(xintercept = tb.calc[[2]], size = 1.2, color = "#26c6da") +
  geom_vline(xintercept = tb.calc[[3]], size = 1.2, color = "#ffa726") +
  ggtitle("Tuberculosis")

