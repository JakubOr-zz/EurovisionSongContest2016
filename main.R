# Usun pakiety
#remove.packages("shiny")
#remove.packages("classInt")
#remove.packages("RColorBrewer")
#remove.packages("rgdal")

# Zainstaluj brakujace pakiety
list.of.packages <- c("shiny", "classInt", "RColorBrewer", "rgdal")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Wylacz pakiety
#detach(package:rgdal, unload = TRUE)
#detach(package:shiny, unload = TRUE)
#detach(package:classInt, unload = TRUE)
#detach(package:RColorBrewer, unload = TRUE)

# Wlacz pakiety
library(shiny)
library(rgdal)
library(RColorBrewer)
library(classInt)

# Ustaw sciezke robocza
getwd()
#setwd("C:/Users/ASUS/Desktop/Studia_Kuba/PWD")
setwd("D:/####Studia/PWD")

# Uruchom aplikacje
runApp("main")
