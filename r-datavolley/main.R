library(aws.s3)
library(datavolley)
library(dplyr)
library(jsonlite)
library(volleyreport)
library(ovlytics)

`%eq%` <- function (x, y) x == y & !is.na(x) & !is.na(y)
single_value_or_na <- function(x) if (length(x) == 1) x else NA
single_value_or_na_char <- function(x) if (length(x) == 1) x else NA_character_
single_value_or_na_int <- function(x) if (length(x) == 1) x else NA_integer_
single_unique_value_or_na_int <- function(x) {
  u <- unique(na.omit(x))
  if (length(u) == 1) u else NA_integer_
}

## mean but if empty vector passed, NA
mean0 <- function(x, ...) {
  if (length(x) < 1 || all(is.na(x))) as(NA, class(x)) else mean(x, na.rm = TRUE)
}

## division, avoiding div by 0 warnings (return NA not NaN)
`%/n/%` <- function(x, y) ifelse(abs(y) < 1e-09, NA_real_, x/y)

## convert to string with "%", but not if NA
prc <- function(z, before = "", after = "%") {
  if (length(z) < 1) z else ifelse(is.na(z), z, paste0(before, z, after))
}


d <- dir("./dvw", pattern = "dvw$", full.names = TRUE)
lx <- lapply(d, dv_read, insert_technical_timeouts = FALSE)
# d <- '{{ outputs.download | jq('map(.uri)') | first }}'
# my_list <- fromJSON(d)
# lx <- lapply(my_list, dv_read, insert_technical_timeouts = FALSE)
px <- bind_rows(lapply(lx, plays))

# only check for duplicate player names
# write.csv(check_player_names(lx, distance_threshold = 4), "players.csv", row.names = FALSE)

# output all plays
write.csv(px, "out/plays.csv", row.names = FALSE)

# output datavolley objects in an array
json_data <- toJSON(lx, pretty=TRUE)
write(json_data, "out/output.json")

# output player vr attack block for google doc
lapply(lx, function(x){
  match_id <- x[["meta"]][["match_id"]]
  if (!dir.exists(paste0("out/",match_id))) {
    dir.create(paste0("out/",match_id))
  }
  players <- bind_rows(x[["meta"]][["players_v"]],x[["meta"]][["players_h"]]) %>%
    select(player_id,name,role)
  for (t in x[["meta"]][["teams"]][["team"]]) {
    # PLAYER STATS 
    att <- vr_attack(x[["plays"]],t, by = "player", file_type = "indoor", style = "ov1")
    blo <- vr_block(x[["plays"]], t, by = "player", style = "ov1")
    write.csv(
      att %>%
        full_join(blo,by="player_id") %>%
        left_join(players,by="player_id"),
      paste0("out/",match_id,"/",t,"_att-blo.csv"),
      row.names = FALSE
    )
    
    # TEAM STATS PER SET
    att <- vr_attack(x[["plays"]],t, by = "set", file_type = "indoor", style = "ov1")
    blo <- vr_block(x[["plays"]], t, by = "set", style = "ov1")
    write.csv(
      att %>%
        mutate(match_id=match_id) %>%
        mutate(team=t),
      paste0("out/",match_id,"/",t,"_att-blo_set.csv"),
      row.names = FALSE
    )
    
    write.csv(
      bind_rows(
        x[["plays"]] %>% dplyr::filter(.data$team %in% t, .data$skill == "Serve") %>% group_by(.data$set_number) %>%
          dplyr::summarize(Tot = n(),
                           Err = sum(.data$evaluation %eq% "Error"),
                           Aces = sum(.data$evaluation %eq% "Ace"),
                           `srvEff%` = prc(round(serve_eff(.data$evaluation) * 100)),
                           # `expBP%` = prc(round(mean0(.data$expBP) * 100)),
                           `BP%` = prc(round(mean0(.data$point_won_by == .data$team) * 100))) %>% ungroup %>% mutate(set_number = as.character(.data$set_number)),
        ## total
        x[["plays"]] %>% dplyr::filter(.data$team %in% t, .data$skill == "Serve") %>%
          dplyr::summarize(set_number = "Total", Tot = n(),
                           Err = sum(.data$evaluation %eq% "Error"),
                           Aces = sum(.data$evaluation %eq% "Ace"),
                           `srvEff%` = prc(round(serve_eff(.data$evaluation) * 100)),
                           # `expBP%` = prc(round(mean0(.data$expBP) * 100)),
                           `BP%` = prc(round(mean0(.data$point_won_by == .data$team) * 100)))
      ) %>%
        mutate(match_id=match_id) %>%
        mutate(team=t),
      paste0("out/",match_id,"/",t,"_srv_set.csv"),
      row.names = FALSE
    )
    write.csv(
      bind_rows(
        x[["plays"]] %>% dplyr::filter(.data$team %in% t, .data$skill == "Reception") %>% group_by(.data$set_number) %>%
          dplyr::summarize(Tot = n(),
                           `Err%` = prc(round(mean0(.data$evaluation %eq% "Error")*100)),
                           `Pos%` = prc(round(mean0(.data$evaluation_code %in% c("+","#")*100))),
                           # `srvEff%` = prc(round(serve_eff(.data$evaluation) * 100)),
                           # `expBP%` = prc(round(mean0(.data$expBP) * 100)),
                           `SO%` = prc(round(mean0(.data$point_won_by == .data$team) * 100))) %>% ungroup %>% mutate(set_number = as.character(.data$set_number)),
        ## total
        x[["plays"]] %>% dplyr::filter(.data$team %in% t, .data$skill == "Reception") %>%
          dplyr::summarize(set_number = "Total", 
                            Tot = n(),
                           `Err%` = prc(round(mean0(.data$evaluation %eq% "Error") * 100)),
                           `Pos%` = prc(round(mean0(.data$evaluation_code %in% c("+","#") * 100))),
                           # `srvEff%` = prc(round(serve_eff(.data$evaluation) * 100)),
                           # `expBP%` = prc(round(mean0(.data$expBP) * 100)),
                           `SO%` = prc(round(mean0(.data$point_won_by == .data$team) * 100)))
      ) %>%
        mutate(match_id=match_id) %>%
        mutate(team=t),
      paste0("out/",match_id,"/",t,"_rcv_set.csv"),
      row.names = FALSE
    )
  }
  srv <- x[["plays"]] %>% dplyr::filter(.data$team %in% t, .data$player_id != "unknown player", .data$skill == "Serve") %>% group_by(.data$player_id) %>%
    dplyr::summarize(Tot = n(),
                     Err = sum(.data$evaluation %eq% "Error"),
                     Aces = sum(.data$evaluation %eq% "Ace"),
                     `srvEff%` = prc(round(serve_eff(.data$evaluation) * 100)),
                     `BP%` = prc(round(mean0(.data$point_won_by == .data$team) * 100)))
  write.csv(
    inner_join(srv,players,by="player_id"),
    paste0("out/",match_id,"/","srv.csv")
  )
})