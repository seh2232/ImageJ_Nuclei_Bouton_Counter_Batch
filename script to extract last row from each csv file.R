setwd("__")
library(readr)
library(openxlsx)
library(svMisc)
library(dplyr)

#set up the dataframe for the loop
res <- as.data.frame(tail(read_csv(dir()[1]), n=1))
#add extra column for the name of the file
res$filename <- NA
res$Region <- NA
#remove any content from the dataframe, keep only the columns and their names
res <- res[FALSE,]
res <- res[,c(1,2,10,11)]
res_boutons <- res
res_nuclei <- res



pb <- txtProgressBar(min = 1, max = length(dir()), style = 3)

for(i in 1:length(dir())){
  if(grepl("Counts", dir()[i])) next
  # temp_res <- as.data.frame(tail(suppressMessages(read_csv(dir()[i])), n=1))
  whole_file <- as.data.frame(suppressMessages(read_csv(dir()[i])))
  temp_res <- tail(whole_file, n=1)
  temp_res$filename <- dir()[i]
  temp_res$Area <- sum(whole_file$Area)
  temp_res$Region <- gsub("(.*)_(.*)_(.*)", "\\2",  dir()[i])
  temp_res <- temp_res[,c(1,2,10,11)]
  if(grepl("Bou", dir()[i])){
    res_boutons <- rbind(res_boutons, temp_res)
  }else{
    res_nuclei <- rbind(res_nuclei, temp_res)
  }
  setTxtProgressBar(pb, i)
}

close(pb)
#rename columns
names(res_boutons) <- c("Boutons Counts", "Boutons Area Sum", "filename", "Region")
names(res_nuclei) <- c("Nuclei Counts", "Nuclei Area Sum", "filename", "Region")

res <- res_boutons %>%
  mutate(`Nuclei Counts` = res_nuclei$`Nuclei Counts`, `Nuclei Area Sum` = res_nuclei$`Nuclei Area Sum`)

#save is as a csv file
write.csv(res, file = paste(getwd(), "Counts results.csv", sep = "/"), row.names = FALSE)

setwd("..")
