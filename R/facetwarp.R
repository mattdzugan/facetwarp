#' Arrange Facets for your ggplot object
#'
#' @param facets A variable, quoted by vars(), defining faceting groups
#' @param macro_x the name of a column which shall be used to arrange facets horizontally
#' @param macro_y the name of a column which shall be used to arrange facets vertically
#' @param nrow,ncol Number of rows and columns.
#' @param strip.position By default, the labels are displayed on the top of
#'   the plot. Using `strip.position` it is possible to place the labels on
#'   either of the four sides by setting \code{strip.position = c("top",
#'   "bottom", "left", "right")}
#' @param labeller A function that takes one data frame of labels and
#'   returns a list or data frame of character vectors. Each input
#'   column corresponds to one factor. Thus there will be more than
#'   one with `vars(cyl, am)`. Each output
#'   column gets displayed as one separate line in the strip
#'   label. This function should inherit from the "labeller" S3 class
#'   for compatibility with [labeller()]. You can use different labeling
#'   functions for different kind of labels, for example use [label_parsed()] for
#'   formatting facet labels. [label_value()] is used by default,
#'   check it for more details and pointers to other options.
#' @examples
#' ggplot(iris)+
#'    geom_point(aes(x=Petal.Width, y=Petal.Length))+
#'    facet_warp(vars(Species), macro_x='Sepal.Width', macro_y='Sepal.Length', nrow = 2)
#' @import ggplot2
#' @export
facet_warp <- function(facets,
                       macro_x, macro_y,
                       nrow = NULL, ncol = NULL,
                       strip.position = "top",
                       labeller = "label_value") {
  ggproto(NULL, FacetWarp,
          params = list(
            facets = rlang::quos_auto_name(facets),
            macro_x = macro_x, # this is the magic variable
            macro_y = macro_y, # this is the magic variable
            strip.position = strip.position,
            labeller = labeller,
            ncol = ncol,
            nrow = nrow
          )
  )
}




FacetWarp <- ggproto("FacetWarp", FacetWrap,

                     # forcing all panels to use fixed scale for simplicity
                     setup_params = function(data, params) {
                       params <- FacetWrap$setup_params(data, params)
                       params$free <- list(x = FALSE, y = FALSE)
                       return(params)
                     },

                     # The compute_layout() method does the work
                     compute_layout = function(data, params) {

                       # create a data frame with one column per facetting
                       # variable, and one row for each possible combination
                       # of values (i.e., one row per panel)
                       panels <- combine_vars(
                         data = data,
                         env = params$plot_env,
                         vars = params$facets,
                         drop = FALSE
                       )

                       # autocompute n_rows and n_cols
                       dims <- ggplot2::wrap_dims(nrow(panels), params$nrow, params$ncol)

                       # core lap algorithm
                       locations <- compute_arrangement(mydata = data,
                                                        macro_x = params$macro_x,
                                                        macro_y = params$macro_y,
                                                        faceter = gsub('~','',as.character(params$facets)),
                                                        n_row = dims[1],
                                                        n_col = dims[2])

                       # Assign each panel a location
                       layout <- data.frame(
                         PANEL = 1:nrow(panels), # panel identifier
                         ROW = locations$ROW,    # row number for the panels
                         COL = locations$COL,    # column number for the panels
                         SCALE_X = 1L,           # all x-axis scales are fixed
                         SCALE_Y = 1L            # all y-axis scales are fixed
                       )

                       # Bind the layout information with the panel identification
                       # and return the resulting specification
                       return(cbind(layout, panels))
                     }
)
