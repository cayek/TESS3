#include <R.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "createDataSet/createDataSet.h"

#include "wrapper_createdataset.h"

void wrapper_createdataset(char **R_input_file, int *R_seed, double *R_percentage,
                     char **R_output_file)
{
        // for random in R
        GetRNGstate();

        createDataSet(*R_input_file, (long long)(*R_seed), *R_percentage,
                      *R_output_file);

        // for random in R
        PutRNGstate();
}
