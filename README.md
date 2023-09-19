# facetwarp <img src="man/figures/logo.png" align="right" width="120"/>

## Introduction

*facetwarp* is an extension of [*ggplot2*](https://ggplot2.tidyverse.org), specifically aimed at assisting in arranging faceted plots.

Typically `facet_wrap` positions your facets alphabetically, but with `facet_warp` you might: 
- layout facets as their categories appear on a map 🗺
- arrange facets as if they themselves are points in a 2D scatter plot ⠞


![](https://github.com/mattdzugan/facetwarp/blob/main/man/figures/demo.gif?raw=true)

# Table of contents

1.  [How it Works](#howitworks)
2.  [Installation](#installation)
3.  [Usage Examples](#examples)
4.  [How to Contribute](#contributing)

## How it Works <a name="howitworks"></a>

`facetwarp` uses a solution to the [Linear Assignment Problem](https://en.wikipedia.org/wiki/Assignment_problem) developed by [Jonker & Volgenant](https://link.springer.com/article/10.1007/BF02278710) to take facets which can be expressed some 2D space, and snap them to a regular grid.

## Installation <a name="installation"></a>

```         
devtools::install_github("mattdzugan/facetwarp")
```

## Usage Examples <a name="examples"></a>

Try it out! (note the **warp** not **wrap** after the `facet`) ✨

```         
library(ggplot2)
library(facetwarp)
ggplot(iris)+
    geom_point(aes(x=Petal.Width, y=Petal.Length))+
    facet_warp(vars(Species), macro_x='Sepal.Width', macro_y='Sepal.Length', nrow = 3, ncol = 3)
```

## How to Contribute <a name="contributing"></a>

This repo is just a brand new baby, so please [open an issue](https://github.com/mattdzugan/facetwarp/issues), or reach out on [twitter... i mean.. x](https://twitter.com/MattDzugan).
