# billionaiRe 0.3.0
* Updated data loading functions so that all 3 xMart databases are available: unprojected
data, projected data, and final input data for the Billions.
* Added in `untransform_hpop_data()` and `untransform_uhc_data()` so that transformed
data could be converted back into the original domain of the raw data.
* Allow multiple columns to be transformed or untransformed at once using the
`transform_...` and `untransform_...` functions for UHC and HPOP Billions.
* Clear error messages added if there are non-distinct rows in `df` for `ind`, `iso3`,
and `year`.

# billionaiRe 0.2.1

* Changed `transform_glucose()` to have a domain of 5.1 to 7.4, previously one of
5.1 to 7.4.
* Fixed pop_links to ensure that IPV double counting correction was correct

# billionaiRe 0.2.0

* Added a `NEWS.md` file to track changes to the package.
* Implemented HEP Billions into pipeline.

# billionaiRe 0.1.0

* Initial release of package. UHC and HPOP Billions available for calculation through the
billionaiRe API.

