load_hpop_gho_data <- function(gho_ids, queries) {
  ghost::gho_data(gho_ids, queries) %>%
    dplyr::select("iso3" = "SpatialDim",
                  "year" = "TimeDim",
                  "value" = "NumericValue",
                  "ind" = "IndicatorCode",
                  "Dim1",
                  "Dim2",
                  "Dim3",
                  "source" = "Comments") %>% # remove once data sources in correct column
    dplyr::group_by(dplyr::across(c("ind", "Dim1", "Dim2", "Dim3", "year", "iso3"))) %>%
    dplyr::summarize(!!sym("value") := mean(.data[["value"]]), # take mean for duplicate values
                     !!sym("source") := paste(unique(.data[["source"]]), collapse = ", "), # keep unique sources for both values
                     .groups = "drop") %>%
    dplyr::mutate(!!sym("source") := replace(.data[["source"]],
                                             !(.data[["ind"]] %in% gho_ids[names(gho_ids) %in% c("anc4", "beds", "pneumo")]), # remove once source available in GHO
                                             NA_character_)) %>%
    dplyr::mutate(!!sym("ind") := names(gho_ids)[match(.data[["ind"]], gho_ids)]) %>%
    dplyr::filter(whotilities::is_who_member(.data[["iso3"]]))
}

wrangle_hpop_data <- function(df) {
  df %>%
    dplyr::mutate(!!sym("Dim1") := gsub('_', '-', .data[["Dim1"]])) %>% # prevent issues when dropping last _
    tidyr::pivot_wider(id_cols = c("iso3", "year"),
                       names_from = c("ind", "Dim1"),
                       values_from = "value") %>%
    dplyr::mutate(male = wppdistro::get_population(.data[["iso3"]], .data[["year"]], sex = "male"),
                  female = wppdistro::get_population(.data[["iso3"]], .data[["year"]], sex = "female"),
                  !!sym("bp_BTSX") := transform_totl_pop(.data[["bp_MLE"]],
                                                         .data[["bp_FMLE"]],
                                                         male,
                                                         female),
                  !!sym("fpg_BTSX") := transform_totl_pop(.data[["fpg_MLE"]],
                                                          .data[["fpg_FMLE"]],
                                                          male,
                                                          female),
                  !!sym("ihr_NA") := ifelse(is.na(.data[['ihr_NA']]),
                                            .data[['ihr2018_NA']],
                                            .data[['ihr_NA']]),
                  !!sym("tb_NA") := replace(.data[["tb_NA"]],
                                            .data[["tb_NA"]] > 100 | .data[["tb_NA"]] == 0,
                                            NA)) %>%
    dplyr::select(-dplyr::any_of(c('male', 'female', 'ihr2018_NA')),
                  -dplyr::matches("*_MLE|*_FMLE")) %>%
    dplyr::rename_with(~sub("_[^_]+$", "", .x)) %>% # remove text after last underscore
    dplyr::mutate(dplyr::across(-c("iso3", "year"),
                                ~ifelse(!is.na(.x), "WHO GHO", NA),
                                .names = "{col}_type")) %>%
    dplyr::rename_with(~paste0(.x, "_value"),
                       .cols = !(dplyr::ends_with("_type") | dplyr::one_of(c("iso3", "year"))))
}

#' @export
asc_normal_impute <- function(df,
                              var,
                              type,
                              iso3 = "iso3",
                              year = "year") {
  df <- dplyr::mutate(df, temp_reg = whotilities::iso3_to_regions(.data[[iso3]]))
  df <- linear_interp_df(df, var, type, iso3, year)
  df <- flat_extrap_df(df, var, type, iso3, year)
  df <- min_impute_df(df, var, type, iso3, year, txt = "flat trend line")
  df <- med_impute_df(df, var, type, c("temp_reg", year), year, txt = "regional median", filter_col = iso3, filter_fn = whotilities::is_large_member_state)
  df %>%
    dplyr::select(dplyr::all_of(c(var, type, iso3, year)))
}

#' @export
pneumo_impute_df <- function(df,
                             pneumo,
                             ari,
                             type,
                             iso3 = "iso3",
                             year = "year",
                             year_range = 2000:2017,
                             txt = "regression") {
  df <- df %>%
    dplyr::mutate(temp_fit = pneumo_model(.data[[pneumo]], .data[[ari]], .data[[iso3]], .data[[year]], year_range))
  df <- linear_interp_df(df, pneumo, type, iso3, year)
  df <- flat_extrap_df(df, pneumo, type, iso3, year)
  df <- min_impute_df(df, pneumo, type, iso3, year, txt = "flat trend line")
  df <- df %>%
    dplyr::mutate(!!sym(pneumo) := ifelse(is.na(.data[[pneumo]]),
                                          101 * exp(temp_fit) / (1 + exp(temp_fit)),
                                          .data[[pneumo]]),
                  !!sym(pneumo) := replace(.data[[pneumo]],
                                           .data[[pneumo]] > 100 & !is.na(.data[[pneumo]]),
                                           100),
                  !!sym(type) := replace(.data[[type]],
                                         is.na(.data[[type]]) & !is.na(.data[[pneumo]]),
                                         txt),
                  !!sym(type) := replace(.data[[type]],
                                           .data[[year]] > 2017 & .data[[type]] == txt,
                                           NA))
  df <- flat_extrap_df(df, pneumo, type, iso3, year)
  df %>%
    dplyr::select(dplyr::all_of(c(iso3, year, pneumo, type)))
}

#' @export
asc_impute <- function(df, asc_vars, pneumo, ari, iso3 = "iso3", year = "year") {
  norm_vals <- paste0(asc_vars, "_value")
  norm_types <- paste0(asc_vars, "_type")
  pneumo_val <- paste0(pneumo, "_value")
  pneumo_type <- paste0(pneumo, "_type")
  ari <- paste0(ari, "_value")
  df <- df %>%
    dplyr::left_join(tidyr::expand(., !!sym(iso3), !!sym(year) := 1975:2019), ., by = c(iso3, year))
  n_df <- purrr::map2(norm_vals,
                      norm_types,
                      ~asc_normal_impute(df, .x, .y),
                      iso3,
                      year) %>%
    purrr::reduce(~dplyr::left_join(.x, .y, by = c(iso3, year)))
  p_df <- pneumo_impute_df(df, pneumo_val, ari, pneumo_type)
  dplyr::left_join(n_df, p_df, by = c(iso3, year))
}

#' @export
asc_transform <- function(df) {
  df %>%
    dplyr::mutate(hwf_value = .data[["phys_value"]] + .data[["nurse_value"]],
                  hwf_type = ifelse(.data[["phys_type"]] == "WHO GHO" & .data[["nurse_type"]] == "WHO GHO",
                                    "WHO GHO",
                                    "imputed")) %>%
    dplyr::select(-dplyr::starts_with(c("phys_", "nurse_"))) %>%
    dplyr::mutate(!!sym("bp_value") := reverse_ind(.data[["bp_value"]]),
                  bp_resc_value = transform_bp(.data[["bp_value"]]),
                  bp_resc_type = .data[["bp_type"]],
                  fpg_resc_value = transform_glucose(.data[["fpg_value"]]),
                  fpg_resc_type = .data[["fpg_type"]],
                  !!sym("tobacco_value") := reverse_ind(.data[["tobacco_value"]]),
                  tobacco_resc_value = transform_tobacco(.data[["tobacco_value"]]),
                  tobacco_resc_type = .data[["tobacco_type"]],
                  beds_resc_value = transform_hosp_beds(.data[["beds_value"]]),
                  beds_resc_type = .data[["beds_type"]],
                  hwf_resc_value = transform_hwf(.data[["hwf_value"]]),
                  hwf_resc_type = .data[["hwf_type"]])
}

#' @export
asc_prepare <- function(df) {
  df <- df %>%
    dplyr::filter(.data[["year"]] >= 2000) %>%
    tidyr::pivot_longer(!dplyr::any_of(c("iso3", "year")),
                        names_to = c("ind", ".value"),
                        names_pattern = "(.*)_([^_]+$)")
  dplyr::mutate(df,
                ind = ifelse(stringr::str_detect(.data[["ind"]], ".*_resc$"),
                             .data[["ind"]],
                             paste0(.data[["ind"]], "_raw")),
  ) %>%
    tidyr::separate(col = .data[["ind"]],
                    into = c("ind", "val_type"),
                    sep = "(\\_)(?=.[^_]+$)") %>%
    tidyr::pivot_wider(names_from = val_type,
                       values_from = value) %>%
    dplyr::mutate(Billions = "UHC",
                  GeoArea_FK = whotilities::iso3_to_names(.data[["iso3"]]),
                  Year_FK = .data[["year"]],
                  Billion_Group = dplyr::case_when(
                    .data[["ind"]] %in% c("fp", "anc4", "dtp3", "pneumo") ~ "RMNCH",
                    .data[["ind"]] %in% c("tb", "art", "itn", "sanitation") ~ "Infectious",
                    .data[["ind"]] %in% c("bp", "fpg", "tobacco") ~ "NCD",
                    .data[["ind"]] %in% c("beds", "hwf", "ihr") ~ "Capacity"
                  ),
                  type = .data[["type"]],
                  use_dash = ifelse(.data[["ind"]] %in% "mort_pneumo", "Yes", "No"),
                  use_cal = ifelse(.data[["ind"]] %in% "mort_pneumo", "Yes", "No"),
                  raw = .data[["raw"]],
                  resc = ifelse(is.na(resc), raw, resc),
                  source = "WHO GHO")
}

hpop_ids <- c(adult_obese = "NCD_BMI_30C",
              child_obese = "NCD_BMI_PLUS2C",
              stunting = "NUTRITION_HA_2",
              wasting = "NUTRITION_WH_2"  ,
              overweight = "NUTRITION_WH2",
              road_safety = "RS_198",
              alcohol = "SA_0000001688",
              ipv = "SDGIPV",
              air_quality = "SDGPM25",
              clean_fuels = "SDGPOLLUTINGFUELS",
              tobacco ="M_Est_tob_curr",
              safe_water = "WSH_SANITATION_SAFELY_MANAGED",
              safe_san = "WSH_WATER_SAFELY_MANAGED",
              # "NCD_CCS_SatFat",
              suicide_mort = "SDGSUICIDE",
              # "CHILDVIOL",
              dev_on_track = "SE_DEV_ONTRK")

hpop_filters <- c(adult_obese = "$filter=Dim1 eq 'BTSX'",
                child_obese = "$filter=Dim1 eq 'BTSX' and dim2 eq 'YEARS10-19'",
                stunting = NA,
                wasting = NA,
                overweight = NA,
                road_safety = NA,
                alcohol = "$filter=Dim1 eq 'BTSX'",
                ipv = "$filter=Dim2 eq '15-49Y'",
                air_quality = NA,
                clean_fuels = NA,
                tobacco = "$filter=Dim1 eq 'BTSX'",
                safe_water = NA,
                safe_san = NA,
                # "NCD_CCS_SatFat",
                suicide_mort = "$filter=Dim1 eq 'BTSX' and Dim2 eq null",
                # "CHILDVIOL",
                dev_on_track = NA)