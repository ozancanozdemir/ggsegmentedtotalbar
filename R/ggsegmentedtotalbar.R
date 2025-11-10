# Suppress NOTES about .data in ggplot2 aes()
utils::globalVariables(".data")
#' Create a segmented total bar plot with custom annotations and labels
#'
#' This function creates a segmented bar plot where each bar represents a group,
#' divided into segments. Additionally, a background box is drawn behind each bar
#' up to the group's total value. Optionally, total values and segment values can
#' be displayed as labels on the plot.
#'
#' The group levels are ordered from the group with the highest total value
#' to the one with the lowest.
#'
#' @param df A data frame containing the data to be plotted.
#' @param group A string specifying the column name for the grouping variable.
#' @param segment A string specifying the column name for the segmenting variable (used for fill color).
#' @param value A string specifying the column name for the value variable (used for the bar heights).
#' @param total A string specifying the column name for the total variable (used for determining the background box height).
#' @param alpha A numeric value (between 0 and 1) controlling the transparency of the background boxes. Default is 0.3.
#' @param color A string specifying the color of the background boxes. Default is "lightgrey".
#' @param border_color A string specifying the border color of the background boxes. Default is "black".
#' @param label Logical. If `TRUE`, adds labels showing total values above the boxes and value labels on each segment. Default is `FALSE`.
#' @param value_label Logical. If `TRUE`, adds labels showing values on each segment. Default is `FALSE`.
#' @param total_label Logical. If `TRUE`, adds labels showing total values above the boxes. Default is same as `value_lavel`.
#' @param value_vjust Numeric. adjust the alignment of values labels. Default is -0.3.
#' @param total_vjust Numeric. adjust the alignment of total values labels. Default is -0.5.
#' @param label_size Numeric. Text size for the labels. Default is 4.
#' @param label_color A string specifying the color of the labels. Default is "black".
#' @param reoder Logical. If `TRUE`, sort by total value in ascending or descending order. The sorting behavior is specified in .desc.
#' @param .desc Logical. If `TRUE`, sort in descending order by total value.
#' @param show_total_legend If `TRUE`, add a legend showing the total.
#' @param name_total_legend A string specifying as the item name when adding a total to the legend. Default is "TOTAL".
#'
#' @return A ggplot object displaying the segmented bar plot with optional annotations and labels.
#'
#' @examples
#' df_ex <- data.frame(
#'   group = rep(c("West", "East", "Central", "South"), each = 3),
#'   segment = rep(c("Consumer", "Corporate", "Home Office"), 4),
#'   value = c(364, 232, 143, 357, 204, 131, 254, 158, 91, 196, 122, 74),
#'   total = rep(c(739, 692, 503, 392), each = 3)
#' )
#' ggsegmentedtotalbar(df_ex, group = "group", segment = "segment",
#'                     value = "value", total = "total", value_label = TRUE)
#'
#' @export
ggsegmentedtotalbar <- function(df, group, segment, value, total,
                                alpha = 0.3, color = "lightgrey",
                                label = FALSE, label_size = 4, label_color = "black",
                                reoder = TRUE, .desc = TRUE) {
                                show_total_legend = FALSE, name_total_legend = "TOTAL") {
                                alpha = 0.3, color = "lightgrey", border_color = "black",
                                label = FALSE, label_size = 4, label_color = "black") {
                                alpha = 0.3, color = "lightgrey",
                                value_label = FALSE, total_label = value_label,
                                value_vjust = -0.3, total_vjust = -0.5,
                                label_size = 4, label_color = "black") {

  # Order group variable by total value
  if(reoder) df[[group]] <- forcats::fct_reorder(df[[group]], df[[total]], .fun = max, .desc = .desc)
  else if(!is.factor(df[[group]])) df[[group]] <- as.factor(df[[group]])

  y_max <- max(df[[value]], df[[total]], na.rm = TRUE)
  y_min <- min(df[[value]], df[[total]], na.rm = TRUE)

  if(y_max >= 0) y_max <- round(y_max + y_max * 0.15)
  else y_max <- 0

  if(y_min >= 0) y_min <- 0
  else y_min <- round(y_min + y_min * 0.15)

  # Base plot
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[group]], y = .data[[value]], fill = .data[[segment]])) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.9), show.legend = if(show_total_legend) TRUE else NA) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.9), alpha = 1) +
    ggplot2::labs(title = "Segmented Total Bar Plot") +
    ggplot2::theme_minimal() +
    ggplot2::ylim(y_min, y_max)

  # Background boxes (rectGrob)
  box_grobs <- lapply(seq_along(levels(df[[group]])), function(i) {
    current_category <- levels(df[[group]])[i]
    y_value <- df[[total]][df[[group]] == current_category][1]
    ggplot2::annotation_custom(
      grob = grid::rectGrob(gp = grid::gpar(col = border_color, fill = color, alpha = alpha)),
      xmin = i - 0.47, xmax = i + 0.47,
      ymin = 0, ymax = y_value
    )
  })

  # Combine plot and boxes
  p_final <- Reduce(`+`, c(list(p), box_grobs))
  p_final <- p_final +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.9))

  if(show_total_legend){
    segment_name <- unique(df[[segment]])

    p_final <- p_final +
      ggplot2::scale_fill_manual(values = c(`names<-`(c(scales::hue_pal()(length(segment_name)), color), c(segment_name, name_total_legend))),
                                 limits = c(segment_name, name_total_legend), drop = FALSE)
  }

  # Add labels if requested
  if (total_label) {
    # Total labels (one per group)
    label_data_total <- df[!duplicated(df[[group]]), c(group, total)]
    label_data_total[[group]] <- factor(label_data_total[[group]], levels = levels(df[[group]]))

    p_final <- p_final +
      ggplot2::geom_text(data = label_data_total,
                         ggplot2::aes(x = .data[[group]], y = .data[[total]], label = .data[[total]]),
                         inherit.aes = FALSE,
                         vjust = ifelse(label_data_total[[total]] >= 0, total_vjust, 1 - total_vjust), size = label_size, color = label_color)
  }
  if (value_label) {
    p_final <- p_final +
      ggplot2::geom_text(ggplot2::aes(label = .data[[value]]),
                         position = ggplot2::position_dodge(width = 0.9),
                         vjust = ifelse(df[[value]] >= 0, value_vjust, 1 - value_vjust), size = label_size, color = label_color)
  }

  return(p_final)
}
