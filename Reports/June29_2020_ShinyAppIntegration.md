## Shiny App Integration:
*by Ryan Bartelme, PhD - June 25th, 2020*

---

### Rationale:

* Integrate Rscripts and output into Shiny App
* Plot output of `bnlearn` structure learning with `hc`

---

### Draft layout of app and visualizations in Inkscape

* draft image goes here

* Users should be able to query the *Sorghum bicolor* BAP analysis to examine relationships using `cpquery` function

* UI suggestions:
  * select output of query
  * number of nodes to query against
  *

### Notes on integration of Rscripts into App framework

* It is possible to call a script from within ShinyApp as `source(some_script.R)`

* This could be useful for operating across the cleaned datasets

###  Notes on executing clean-up script as local job within app

* may not be entirely necessary

* plumber api is an option

* often used for debugging when building app

* Local jobs can be executed inside the Rstudio IDE but remote job feature is for Rstudio server pro

###  Determine hosting of app

* Can the network learning/fitting/analyses be done inside shiny?
  * This seems better to have been done previously and use the app to query the results

* Could this be hosted on Shinyapps.io? Or permanently on CyVerse?
  *

* Document as a project on personal website
