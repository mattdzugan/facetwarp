#' Compute Arrangement Using Jonker & Volgenant algorithm
#'
#' @param mydata A data frame which contains the {macro_x, macro_y, faceter} columns
#' @param macro_x the name of a column which shall be used to arrange facets horizontally
#' @param macro_y the name of a column which shall be used to arrange facets vertically
#' @param faceter the column name defining faceting groups
#' @param nrow,ncol Number of rows and columns.
#' @import dplyr
#' @import lpSolve
compute_arrangement <- function(mydata, macro_x, macro_y, faceter, n_row, n_col){

  library(lpSolve)
  dt <- as.data.frame(mydata)

  ##############################################################################
  ##############################################################################
  ##############################################################################
  # Inputs

  dtu <- dt %>%
    group_by(!!as.name(faceter)) %>%
    summarise(x = median(!!as.name(macro_x), na.rm = TRUE),
              y = median(!!as.name(macro_y), na.rm = TRUE)) %>%
    select(x, y, !!as.name(faceter))

  nrow <- n_row
  ncol <- n_col


  ##############################################################################
  ##############################################################################
  ##############################################################################
  # Normalize

  grid <- expand.grid(ROW = 1:nrow, COL = 1:ncol) %>%
    mutate(x_norm = (COL-1)/(ncol-1),
           y_norm = 1 - (ROW-1)/(nrow-1))

  dtu <- dtu %>%
    mutate(x_min  = min(x),
           x_max  = max(x),
           y_min  = min(y),
           y_max  = max(y)) %>%
    mutate(x_norm = (x-x_min)/(x_max-x_min),
           y_norm = (y-y_min)/(y_max-y_min))


  ##############################################################################
  ##############################################################################
  ##############################################################################
  # Costs
  # (row is facet, column is gridspace)

  costs <- matrix(data=0, nrow=nrow(grid), ncol=nrow(grid)) #grid on both sides
  for(ii in 1:nrow(dtu)){
    for(jj in 1:nrow(grid)){
      costs[ii,jj] <- sqrt((dtu[ii, ]$x_norm - grid[jj, ]$x_norm)^2 +
                             (dtu[ii, ]$y_norm - grid[jj, ]$y_norm)^2)
    }
  }

  ##############################################################################
  ##############################################################################
  ##############################################################################
  # Eval
  # (row is facet, column is gridspace)

  sln <- lp.assign(costs)
  assignments <- sln$solution

  facet2grid <- c()
  for(ii in 1:nrow(dtu)){
    facet2grid[ii] <- round(sum(assignments[ii, ]*(1:nrow(grid))))
  }
  facet2grid_dt <- data.frame(facet_id = 1:nrow(dtu),
                              grid_id = facet2grid)


  ##############################################################################
  ##############################################################################
  ##############################################################################
  # Out
  dtu  <- dtu  %>% mutate(facet_id = 1:nrow(dtu))
  grid <- grid %>% mutate(grid_id  = 1:nrow(grid))

  dtu <- merge(dtu, facet2grid_dt, by='facet_id', all.x=TRUE)
  dtu <- merge(dtu, grid[, c('grid_id','ROW','COL')], by='grid_id', all.x=TRUE)

  dtu <- dtu %>%
    arrange(facet_id) %>%
    select(facet_id, ROW, COL)

  return(dtu)
}
