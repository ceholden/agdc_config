# agdc_config
Configuration and environment details for running the AGDCv2

This repo includes an `environment.yaml` file that is used by `conda` to
install all of the dependencies of the AGDC. To use it, first install
`conda` (details at http://conda.pydata.org/docs/) and then create a
new `conda` environment using this `environment.yaml` as follows:

``` bash
conda env create -f environment.yaml
```
