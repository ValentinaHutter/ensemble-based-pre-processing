# Open files
file2 <- "./data/Values.csv"
data2 <- read.csv(file2)
head(data2)
file4 <- "./data/Errors.csv"
data4 <- read.csv(file4)
head(data4)

data_all <- data.frame(
  day = data2$days,
  hour = data2$hours
)
head(data_all)

#to install a package insert: 
install.packages("gamlss")
#load package
library(gamlss)
install.packages("crch")
#load package
library(crch)


# We iterate over the stations, in this data set are only two stations 
index <- c(2:3)*2
head(index)

# the coefficients will be appended to r and s
r <- c()
s <- c()
# the prediction is done for all days and hours
predicted <- data.frame(
  day = data_all$day,
  hour = data_all$hour
)
head(predicted)

# this is a test to see if the names are correct
for (i in index){
  name <- colnames(data2)[i]
  name_obs <- colnames(data2)[i+1]
  print(name)
  print(name_obs)
}

# this starts the computation of the climatology and the coefficients
for (i in index){
  name <- colnames(data2)[i]
  name_obs <- colnames(data2)[i+1]
  print(name)
  data3 <- data.frame(
    day = data2$days,
    hour = data2$hours, 
    fg = data2[,i],
    obs = data2[,(i+1)],
    fg_sd = data4[,i],
    obs_sd = data4[,(i+1)]
  )
  # Only pick values before 2020, cross validation needs to exclude 2020
  train <- data.frame(
    fg = data3$fg[0:36240],
    obs = data3$obs[0:36240],
    day = data3$day[0:36240],
    hour = data3$hour[0:36240],
    fg_sd = log(data3$fg_sd[0:36240]),
    obs_sd = data3$obs_sd[0:36240]
  )
  
  train = na.omit(train)
  foo <- as.formula('fg ~ sin(2*pi*day/365)+sin(4*pi*day/365)+cos(2*pi*day/365)+cos(4*pi*day/365)+sin(2*pi/24*hour)+cos(2*pi/24*hour)') 
  fit_fg <- gamlss(foo, sigma.formula = ~ sin(2*pi*day/365)+sin(4*pi*day/365)+cos(2*pi*day/365)+cos(4*pi*day/365)+sin(2*pi/24*hour)+cos(2*pi/24*hour),  data = train)
  foo <- as.formula('obs ~ sin(2*pi*day/365)+sin(4*pi*day/365)+cos(2*pi*day/365)+cos(4*pi*day/365)+sin(2*pi/24*hour)+cos(2*pi/24*hour)') 
  fit_obs <- gamlss(foo, sigma.formula = ~ sin(2*pi*day/365)+sin(4*pi*day/365)+cos(2*pi*day/365)+cos(4*pi*day/365)+sin(2*pi/24*hour)+cos(2*pi/24*hour),  data = train)
  foo <- as.formula('fg_sd ~ sin(2*pi*day/365)+sin(4*pi*day/365)+cos(2*pi*day/365)+cos(4*pi*day/365)+sin(2*pi/24*hour)+cos(2*pi/24*hour)') 
  fit_sd <- gamlss(foo, sigma.formula = ~ sin(2*pi*day/365)+sin(4*pi*day/365)+cos(2*pi*day/365)+cos(4*pi*day/365)+sin(2*pi/24*hour)+cos(2*pi/24*hour),  data = train)
  
  sd_obs <- (train$obs-fit_obs$mu.fv)/fit_obs$sigma.fv
  sd_fg <- (train$fg-fit_fg$mu.fv)/fit_fg$sigma.fv
  sd <- data.frame(
    sd_fg = sd_fg,
    sd_obs = sd_obs
  )
  CRCH <- crch(sd_obs ~ sd_fg, data = sd, dist = "gaussian")
  I = coef(CRCH)
  r <- append(r, name)
  r <- append(r, I[1])
  r <- append(r, I[2])
  
  s_obs <- log(train$obs_sd/fit_obs$sigma.fv)
  s_fg <- (train$fg_sd-fit_sd$mu.fv)/fit_sd$sigma.fv
  sd_s <- data.frame(
    sd_fg = s_fg,
    sd_obs = s_obs
  )
  CRCHs <- crch(sd_fg ~ sd_obs, data = sd_s, dist = "gaussian")
  Is = coef(CRCHs)
  s <- append(s, name)
  s <- append(s, Is[1])
  s <- append(s, Is[2])
  fg_mu <- predict(fit_fg, what = "mu", newdata=data_all)
  fg_sg <- predict(fit_fg, what = "sigma", newdata=data_all)
  obs_mu <- predict(fit_obs, what = "mu", newdata=data_all)
  obs_sg <- predict(fit_obs, what = "sigma", newdata=data_all)
  sd_mu <- predict(fit_sd, what = "mu", newdata=data_all)
  sd_sg <- predict(fit_sd, what = "sigma", newdata=data_all)
  
  predicted$f = fg_mu
  predicted$fs = fg_sg
  predicted$o = obs_mu
  predicted$os = obs_sg
  predicted$sd = sd_mu
  predicted$sds = sd_sg
  names(predicted)[names(predicted)=="f"] <- paste(name,'_mu')
  names(predicted)[names(predicted)=="fs"] <- paste(name,'_sg')
  names(predicted)[names(predicted)=="o"] <- paste(name_obs,'_mu')
  names(predicted)[names(predicted)=="os"] <- paste(name_obs,'_sg')
  names(predicted)[names(predicted)=="sd"] <- paste(name,'_mu_sd')
  names(predicted)[names(predicted)=="sds"] <- paste(name,'_sg_sd')
  
  head(predicted)
}

# Look at the data and save it
print(r)
print(s)
head(predicted)
write.csv(predicted, './data/Climatology.csv')
write.csv(r, './data/Coefficients.csv')
write.csv(s, './data/CoefficientsSigma.csv')

