

args <- commandArgs(trailingOnly = TRUE)

patchinfo_file <- args[1]

df_patchinfo <- read.table(patchinfo_file)

# Adjust arm C to be an intervention community
df_patchinfo[2,1] <- 1

# Write to disk (in same location)
write.table(df_patchinfo, patchinfo_file, sep = " ", 
    row.names = FALSE, col.names = FALSE)


