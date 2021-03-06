#' Dataset of indicators used within the Billions calculations.
#'
#' A dataset containing dashboard and analysis indicator codes and their uses within the GPW13
#' Billions.
#'
#' @format A data frame with `r nrow(indicator_df)` rows and `r ncol(indicator_df)` variables:
#' \describe{
#'   \item{dashboard_id}{Dashboard ID used within the GPW13 xMart4 instance}
#'   \item{analysis_code}{Code used in the analysis scripts within the billionaiRe package}
#'   \item{gho_code}{GHO storage code for indicator}
#'   \item{uhc}{Logical, is a UHC Billions indicator}
#'   \item{hpop}{Logical, is an HPOP Billions indicator}
#'   \item{hep}{Logical, is a HEP Billions indicator}
#' }
"indicator_df"

#' HPOP Billion population links
#'
#' A dataset linking each HPOP Billion indicator to relevant population groups
#' to be used for double counting correction. Used within `generate_hpop_populations()`.
#'
#' @format A data frame with `r nrow(pop_links)` rows and `r ncol(pop_links)` variables:
#' \describe{
#'   \item{ind}{HPOP indicator code.}
#'   \item{pop_group}{Population group.}
#' }
"pop_links"

#' Socio-Demographic Index data
#'
#' Used internally to transform road safety data for the HPOP Billion. Exact methods available in methods report.
#'
#' @format A data frame with `r nrow(sdi_ratio)` rows and `r ncol(sdi_ratio)` variables:
#' \describe{
#'   \item{iso3}{Country ISO3 codes.}
#'   \item{sdiratio}{SDI ratio.}
#' }
"sdi_ratio"

#' HPOP generated example data
#'
#' Generated (fake) HPOP data used to test the Billions calculations code within the billionaiRe
#' package.
#'
#' See the HPOP vignette for its example use:
#'
#' \href{../doc/hpop.html}{\code{vignette("hpop", package = "billionaiRe")}}
#'
#' @format A data frame with `r nrow(hpop_df)` rows and `r ncol(hpop_df)` variables:
#' \describe{
#'   \item{iso3}{Country ISO3 codes.}
#'   \item{year}{Year.}
#'   \item{ind}{HPOP indicator code.}
#'   \item{value}{Raw indicator value.}
#' }
"hpop_df"

#' UHC example data
#'
#' Fake UHC data used to test the Billions calculations code within the billionaiRe
#' package.
#'
#' See the UHC vignette for its example use:
#'
#' \href{../doc/uhc.html}{\code{vignette("uhc", package = "billionaiRe")}}
#'
#' @format A data frame with `r nrow(uhc_df)` rows and `r ncol(uhc_df)` variables:
#' \describe{
#'   \item{iso3}{Country ISO3 codes.}
#'   \item{year}{Year.}
#'   \item{ind}{UHC indicator code.}
#'   \item{value}{Raw indicator value.}
#' }
"uhc_df"

#' HEP generated example data
#'
#' Generated (fake) HEP data used to test the Billions calculations code within the billionaiRe
#' package.
#'
#' See the HEP vignette for its example use:
#'
#' \href{../doc/hep.html}{\code{vignette("hep", package = "billionaiRe")}}
#'
#' @format A data frame with `r nrow(hep_df)` rows and `r ncol(hep_df)` variables:
#' \describe{
#'   \item{iso3}{Country ISO3 codes.}
#'   \item{year}{Year.}
#'   \item{ind}{HPOP indicator code.}
#'   \item{value}{Raw indicator value.}
#'   \item{type}{Data type.}
#' }
"hep_df"

#' Country shares data
#'
#' Country shares data for UHC and HPOP Billions for all 194 WHO member
#' states.
#'
#' @format A data frame with `r nrow(uhc_df)` rows and `r ncol(uhc_df)` variables:
#' \describe{
#'   \item{iso3}{Country ISO3 codes.}
#'   \item{billion}{Relevant billion}
#'   \item{share_n}{Share, in number of people.}
#'   \item{share_perc}{Share, as percent of total projected population in 2023.}
#' }
"country_shares"
