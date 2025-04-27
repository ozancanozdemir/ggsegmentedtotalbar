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
#' @param label Logical. If `TRUE`, adds labels showing total values above the boxes and value labels on each segment. Default is `FALSE`.
#' @param label_size Numeric. Text size for the labels. Default is 4.
#' @param label_color A string specifying the color of the labels. Default is "black".
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
#'                     value = "value", total = "total", label = TRUE)
#'
#' @export
ggsegmentedtotalbar <- function(df, group, segment, value, total,
                                alpha = 0.3, color = "lightgrey",
                                label = FALSE, label_size = 4, label_color = "black") {

  # Order group variable by total value
  df[[group]] <- forcats::fct_reorder(df[[group]], df[[total]], .fun = max, .desc = TRUE)

  # Base plot
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[group]], y = .data[[value]], fill = .data[[segment]])) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.9)) +
    ggplot2::labs(title = "Segmented Total Bar Plot") +
    ggplot2::theme_minimal() +
    ggplot2::ylim(0, round(max(df[[total]]) + max(df[[total]]) * 0.15))

  # Background boxes (rectGrob)
  box_grobs <- lapply(seq_along(levels(df[[group]])), function(i) {
    current_category <- levels(df[[group]])[i]
    y_value <- df[[total]][df[[group]] == current_category][1]
    ggplot2::annotation_custom(
      grob = grid::rectGrob(gp = grid::gpar(fill = color, alpha = alpha)),
      xmin = i - 0.47, xmax = i + 0.47,
      ymin = 0, ymax = y_value
    )
  })

  # Combine plot and boxes
  p_final <- Reduce(`+`, c(list(p), box_grobs))

  # Add labels if requested
  if (label) {
    # Total labels (one per group)
    label_data_total <- df[!duplicated(df[[group]]), c(group, total)]
    label_data_total[[group]] <- factor(label_data_total[[group]], levels = levels(df[[group]]))

    p_final <- p_final +
      ggplot2::geom_text(data = label_data_total,
                         ggplot2::aes(x = .data[[group]], y = .data[[total]], label = .data[[total]]),
                         inherit.aes = FALSE,
                         vjust = -0.5, size = label_size, color = label_color) +
      ggplot2::geom_text(ggplot2::aes(label = .data[[value]]),
                         position = ggplot2::position_dodge(width = 0.9),
                         vjust = -0.3, size = label_size, color = label_color)
  }

  return(p_final)
}
