library(aws.s3)
library(datavolley)
library(dplyr)
library(jsonlite)
library(purrr)
library(ovlytics)
# library(duckdb)

# directory containing all list of dvw files
d <- dir("./dvw", pattern = "dvw$", full.names = TRUE)
# read each file
lx <- lapply(d, dv_read, insert_technical_timeouts = FALSE)

# open duckDB connection
# con <- duckdb::dbConnect(duckdb::duckdb(),"out/datavolley.db")

# remap inconsitent team names to team_id
lx <- remap_team_names(lx, data.frame(from="DALHOUSIE TIGERS", to="M-DALHOUSIE TIGERS", team_id="MRDT"))
lx <- remap_team_names(lx, data.frame(from="MONTREAL", to="M-MONTREAL CARABINS", team_id="MRMC"))
lx <- remap_team_names(lx, data.frame(from="UNB", to="M-UNB REDS", team_id="MRUR"))


# combined plays object
px <- bind_rows(lapply(lx, plays))
# create or replace plays table
# dbWriteTable(con,"plays",data.frame(px),overwrite = TRUE)
write.csv(px,"out/plays.csv", row.names = FALSE)
# create or replace summary table
# duckdb::dbWriteTable(con,"summary",dvlist_summary(lx)[["ladder"]],overwrite=TRUE)
write.csv(dvlist_summary(lx)[["ladder"]],"out/summary.csv",row.names = FALSE)

# TODO
# only check for duplicate player names
# write.csv(check_player_names(lx, distance_threshold = 4), "players.csv", row.names = FALSE)

# TODO: investigate saving the entire lx object in objectStorage
# output datavolley objects in an array
json_data <- toJSON(lx, pretty=TRUE)
write(json_data, "out/output.json")

# Initialize empty dataframes to store aggregated results
players_df <- data.frame() 

# Apply function to each element in lx

# Iteratively combine each element
for (x in lx) {
  players <- bind_rows(x[["meta"]][["players_v"]], x[["meta"]][["players_h"]])
  players_df <- Reduce(function(x, y) bind_rows(x, y) %>% distinct(player_id, number, firstname,lastname,role), list(players,players_df))
}

write.csv(players_df, "out/players.csv")

# augment plays using ovlytics
augmented_px <- ov_augment_plays(
  px,
  to_add = c("touch_summaries", "setters"),
  use_existing = TRUE
)
# create or replace augmented plays table
# dbWriteTable(con,"augmented_plays",data.frame(px),overwrite = TRUE)
write.csv(augmented_px,"out/augmented_plays.csv",row.names=FALSE)
# dbDisconnect(con)
# TODO: setter distribution simulation
