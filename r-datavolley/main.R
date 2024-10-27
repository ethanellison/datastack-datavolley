library(aws.s3)
library(datavolley)
library(dplyr)
library(jsonlite)
# library(volleyreport)
library(ovlytics)
library(duckdb)

# directory containing all list of dvw files
d <- dir("./dvw", pattern = "dvw$", full.names = TRUE)
# read each file
lx <- lapply(d, dv_read, insert_technical_timeouts = FALSE)

# open duckDB connection
con <- duckdb::dbConnect(duckdb::duckdb(),"out/datavolley.db")

# combined plays object
px <- bind_rows(lapply(lx, plays))

# create or replace plays table
dbWriteTable(con,"plays",data.frame(px),overwrite = TRUE)

# create or replace summary table
duckdb::dbWriteTable(con,"summary",dvlist_summary(lx)[["ladder"]],overwrite=TRUE)

# TODO
# only check for duplicate player names
# write.csv(check_player_names(lx, distance_threshold = 4), "players.csv", row.names = FALSE)

# TODO: investigate saving the entire lx object in objectStorage
# output datavolley objects in an array
json_data <- toJSON(lx, pretty=TRUE)
write(json_data, "out/output.json")

lapply(lx, function(x){
  # combine home and away players and overwrite players_db
  players <- bind_rows(x[["meta"]][["players_v"]],x[["meta"]][["players_h"]])
  dbWriteTable(con,"players",players,overwrite = TRUE)  
})

# augment plays using ovlytics
augmented_px <- ov_augment_plays(
  px,
  to_add = c("touch_summaries", "setters"),
  use_existing = TRUE
)
# create or replace augmented plays table
dbWriteTable(con,"augmented_plays",data.frame(px),overwrite = TRUE)

dbDisconnect(con)
# TODO: setter distribution simulation
