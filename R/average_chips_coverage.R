
##########
# Preamble
# --------

library(tidyverse)
library(tidyr)

param_dir <- "parameters"


triplet_to_com_by_arm <- list(c(2, 1), c(5, 6), c(8, 9), c(10, 11), c(14, 13), c(16, 18), c(19, 20))

for(triplet in 1:7){

# Set community numbers by triplet
CA <- triplet_to_com_by_arm[[triplet]][1]
CB <- triplet_to_com_by_arm[[triplet]][2]

output_dir <- file.path(param_dir, paste0("average_chips_coverage_triplet_", triplet))

if (!dir.exists(output_dir)) {dir.create(output_dir)}

# Load "times" files (all other variables are country-specific, so same across triplet)
df_times <- read.csv(
    file.path(param_dir, paste0("PARAMS_COMMUNITY", CA, "_ACCEPTED"), "param_processed_patch0_times.csv"), sep = " ")

chips_times <- list(
    "CHIPS_YEAR1_START" = c(),
    "CHIPS_YEAR1_END"= c(),
    "CHIPS_YEAR2_START" = c(),
    "CHIPS_YEAR2_END" = c(),
    "CHIPS_YEAR3_START" = c(),
    "CHIPS_YEAR3_END" = c())

rounds <- c(1, 2, 3, "posttrial")

for(round in rounds){

# Load CHiPs coverage files
dfa <- read.csv(file.path(param_dir, paste0("PARAMS_COMMUNITY", CA, "_ACCEPTED"), paste0("param_processed_patch0_chipsuptake_round", round, ".csv")), sep = " ")

dfb <- read.csv(file.path(param_dir, paste0("PARAMS_COMMUNITY", CB, "_ACCEPTED"), paste0("param_processed_patch0_chipsuptake_round", round, ".csv")), sep = " ")


# Check odd delimiters on header row (if all final column is NA)
if(sum(is.na(dfb$prop_hiv_status_known_3MF80)) == NROW(dfb)){
    colnames <- names(dfb)
    dfb_new <- data.frame(0:47, 1, 0:47, dfb[,3:128])
    names(dfb_new) <- colnames
    dfb <- dfb_new
}

if(sum(is.na(dfa$prop_hiv_status_known_3MF80)) == NROW(dfa)){
    colnames <- names(dfa)
    dfa_new <- data.frame(0:47, 1, 0:47, dfa[,3:128])
    names(dfa_new) <- colnames
    dfa <- dfa_new
}

# Both to wide dataset.  
dfa_wide <- dfa %>%
  pivot_longer(
    prop_hiv_status_known_3MM18:prop_hiv_status_known_3MF80,
    names_to = c("sex", "age"),
    names_pattern = "prop_hiv_status_known_3M(.)(..)", 
    values_to = "prop_hiv_status_known_3M")

# SA columnn names seem to have a "_round" prefix on time variables that has crept in
if(triplet > 4){
    names(dfa_wide) <- c("time", "year", "t_step", "sex", "age", "prop_hiv_status_known_3M", "arm")
}

dfb_wide <- dfb %>%
  pivot_longer(
    prop_hiv_status_known_3MM18:prop_hiv_status_known_3MF80,
    names_to = c("sex", "age"),
    names_pattern = "prop_hiv_status_known_3M(.)(..)", 
    values_to = "prop_hiv_status_known_3M")

if(triplet > 4){
    names(dfb_wide) <- c("time", "year", "t_step", "sex", "age", "prop_hiv_status_known_3M", "arm")
}

# Add arm and stack
dfa_wide$arm <- "A"
dfb_wide$arm <- "B"


# Final minimum and maximum of times
min_a <- min(dfa_wide$time)
max_a <- max(dfa_wide$time)

min_b <- min(dfb_wide$time)
max_b <- max(dfb_wide$time)

min_both <- min(min_a, min_b)
max_both <- max(max_a, max_b)

# Save time variables ... 
if(round != "posttrial"){
    chips_times[[paste0("CHIPS_YEAR", round, "_START")]] <- min_both
    chips_times[[paste0("CHIPS_YEAR", round, "_END")]] <- max_both
}

# Fill in zeros for the missing period of the start of the CHiPs round
if(min_a != min_b){
    if(min_a < min_b){
        
        df_new_rows <- subset(dfa_wide, dfa_wide$time < min_b)
        df_new_rows$prop_hiv_status_known_3M <- 0
        
        # Append to dataframe for community B
        dfb_wide <- rbind(df_new_rows, dfb_wide)
        
    }else{
        
        df_new_rows <- subset(dfb_wide, dfb_wide$time < min_a)
        df_new_rows$prop_hiv_status_known_3M <- 0
        
        dfa_wide <- rbind(df_new_rows, dfa_wide)
    }
}

# Fill in zeros for the missing period of the end of the CHiPs round
if(max_a != max_b){
    if(max_a > max_b){
        
        df_new_rows <- subset(dfa_wide, dfa_wide$time > max_b)
        df_new_rows$prop_hiv_status_known_3M <- 0
        
        # Append to dataframe for community B
        dfb_wide <- rbind(dfb_wide, df_new_rows)
        
    }else{
        
        df_new_rows <- subset(dfb_wide, dfb_wide$time > max_a)
        df_new_rows$prop_hiv_status_known_3M <- 0
        
        dfa_wide <- rbind(dfa_wide, df_new_rows)
    }
}

if(NROW(dfa_wide) != NROW(dfb_wide)){
    print("ERROR: Row dimensions are not identical")
}

# Combine into a single dataset
df_wide <- rbind(dfa_wide, dfb_wide)

df_wide$sex <- factor(df_wide$sex, ordered = T, levels = c("M", "F"))

# Take average for same time point.  
df_avg <- df_wide %>%
  group_by(time, year, t_step, sex, age) %>%
  summarise(prop_hiv_status_known_3M = mean(prop_hiv_status_known_3M))

# Make wide dataset
df_avg_wide <- df_avg %>%
  pivot_wider(
    names_from = c(sex, age),
    names_sep = "",
    names_glue = "prop_hiv_status_known_3M{sex}{age}",
    values_from = prop_hiv_status_known_3M) %>%
    arrange(year, t_step)

# Save to disk (for both patches)
for(p in c(0, 1)){
write.table(df_avg_wide, 
    file.path(output_dir, paste0("param_processed_patch", p, "_chipsuptake_round", round, ".csv")), 
    sep = " ", row.names = FALSE, quote = FALSE)
}

}

# Adjust the "times" dataframe for the variables ... 

for(col in names(chips_times) ){
    df_times[[col]] <- chips_times[[col]]
}

for(p in c(0, 1)){
write.table(df_times, 
    file.path(output_dir, paste0("param_processed_patch", p, "_times.csv")), 
    sep = " ", row.names = FALSE, quote = FALSE)
}

}

