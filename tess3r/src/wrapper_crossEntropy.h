#ifndef wrapper_crossEntropy_H
#define wrapper_crossEntropy_H

void wrapper_crossEntropy(char **R_genotype_file, char **R_missing_data_file,
                    char **R_Q_file, char **R_F_file, int *R_K, int *R_ploidy,
                    double *all_ce, double *masked_ce);

#endif                          // wrapper_crossEntropy_H

