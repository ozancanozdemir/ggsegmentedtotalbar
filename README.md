# ggsegmentedtotalbar R package<img width = 150px height = 150px src="https://github.com/user-attachments/assets/73d1a505-64c0-4329-9bf3-01c203412662" align="right" />

It is the first ggplot2-based R package to create the segmented total bar plot in R. 

## Installation

You can install the development version of ggsegmentedtotalbar like so:

``` r
devtools::install_github("https://github.com/ozancanozdemir/ggsegmentedtotalbar")
```

It is on its way to CRAN! 


## Details 

Kevin Flerlage, who is a data visualization specialist, suggested a great alternative to a stacked bar plot on [his blog](https://www.flerlagetwins.com/2025/04/the-best-alternative-to-stacked-bar.html). He called this new alternative a "segmented total bar plot". This R package `ggsegmentedtotalbar` implements this idea. The package is built on top of the `ggplot2` package, which is a popular data visualisation package in R. The `ggsegmentedtotalbar` function creates a segmented total bar plot with custom annotations (boxes) added for each group. The height of each box is determined by the `Total` value associated with each group.

The core thing behind the usage of `ggsegmentedtotalbar` is to create a data frame with the following columns:
  
- `group`: A string representing the name of the grouping variable.
- `segment`: A string representing the name of the segmenting variable.
- `value`: A string representing the name of the value variable (used for the height of bars).
- `total`: A string representing the name of the total variable (used for determining the box height for each group).

The good thing is that your data frame does not have to have the same column names. However, you need to specify the names of the columns in the data frame when calling the `ggsegmentedtotalbar` function correctly.

The function `ggsegmentedtotalbar` takes a data frame and the names of the columns as arguments. It creates a bar plot based on grouped data with annotations (boxes) added for each group. The height of each box is determined by the `Total` value associated with each group.

## Usage 

``` r
# Example data frame
df_ex <- data.frame(
  group = c("A", "A","A","B", "B","B","C","C","C","D","D","D"),
  segment = c("X","Y","Z", "X","Y","Z", "X","Y","Z","X","Y","Z"),
  value = c(10, 20, 30, 40,50,60, 70,80,90, 100, 110, 120),
  total = c(60,60,60, 150,150,150, 240,240,240, 360,360,360)
)
```

```r
# Create the segmented total bar plot
p <- ggsegmentedtotalbar(df_ex, "group", "segment", "value", "total")
# Print the plot
print(p)
```

![image](https://github.com/user-attachments/assets/219fe31b-5156-4f81-8631-0e3aa339a359)

The function also provides three parameters that you can use to customize the plot:
  
- `alpha`: A numeric value (between 0 and 1) controlling the transparency of the background boxes. Default is 0.3.
- `color`: A string specifying the color of the background boxes. Default is "lightgrey".
- `label`: Logical. If `TRUE`, adds labels showing total values above the boxes and value labels on each segment. Default is `FALSE`.

```r
# Create the segmented total bar plot with labels
p <- ggsegmentedtotalbar(df_ex, "group", "segment", "value", "total",
                         label = TRUE, label_size = 4, label_color = "black")
# Print the plot
print(p)
```

![image](https://github.com/user-attachments/assets/3530b421-911e-47d4-9c2b-4a0a9f303625)

```r
# Create the segmented total bar plot with labels and different total box. 
p <- ggsegmentedtotalbar(df_ex, "group", "segment", "value", "total",
                         label = TRUE, label_size = 4, label_color = "black",
                         alpha = 0.2, color = "steelblue")
# Print the plot
print(p)
```

![image](https://github.com/user-attachments/assets/ca0b9075-f837-4ca8-a6f7-10e866b2749d)


Apart from these parameters, you can also customize your plot by utilizing ```ggplot2``` related functions. Here is another example. 

```r
# Create the segmented total bar plot with labels and different total box.
p <- ggsegmentedtotalbar(df_ex, "group", "segment", "value", "total",
                         label = TRUE, label_size = 4, label_color = "black",
                         alpha = 0.2, color = "steelblue") +
  ggplot2::labs(title = "Segmented Total Bar Plot with Custom Annotations",
                x = "Group", y= "Value") +
  ggplot2::theme_test() +
  ggplot2::theme(
    plot.title = ggplot2::element_text(hjust = 0.5),
    axis.text.x = ggplot2::element_text(face= "bold", hjust = 1),
    axis.text.y = ggplot2::element_text(face= "bold", hjust = 1),
    legend.position = "top",
    legend.title = ggplot2::element_blank(),
  )

# Print the plot
print(p)
```

![image](https://github.com/user-attachments/assets/8b868cc8-b931-4289-9a02-c447680c0fe2)
