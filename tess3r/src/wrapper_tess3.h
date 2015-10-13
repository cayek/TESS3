#ifndef wrapper_tess3_H
#define wrapper_tess3_H

void wrapper_tess3(char **R_genotype_file, char **R_coord_file, int *R_K, 
		   double *R_alpha, double *R_tol,
		   double *R_percentage, int *R_iteration, long long *R_seed,
		   int *R_ploidy, int *R_num_proc, char **R_input_file_Q,
		   char **R_output_file_Q, char **R_output_file_G, char **R_output_file_FST, char **R_output_file_sum,
		   int *I, double *all_ce, double *masked_ce, int *n, int *L);

#endif                          // wrapper_tess3_H
