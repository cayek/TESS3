#include <R.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "sNMF/sNMF.h"
#include "sNMF/register_snmf.h"

#include "wrapper_tess3.h"

void wrapper_tess3(char **R_genotype_file,
																			char **R_coord_file,
																			int *R_K,
																			double *R_alpha,
																			double *R_tol,
																			double *R_percentage,
																			int *R_iteration,
																			long long *R_seed,
																			int *R_ploidy,
																			int *R_num_proc,
																			char **R_input_file_Q,
																			char **R_input_file_W,
																			char **R_output_file_Q,
																			char **R_output_file_G,
																			char **R_output_file_FST,
																			char **R_output_file_sum,
																			int *I,
																			double *all_ce,
																			double *masked_ce,
																			int *n,
																			int *L,
																			double *times)
{
								// for random in R
								GetRNGstate();

								// parameters allocation
								sNMF_param param = (sNMF_param) calloc(1, sizeof(snmf_param));

								// init parameters
								init_param_snmf(param);
								param->K = *R_K;
								param->seed = *R_seed;
								param->maxiter = *R_iteration;
								param->num_thrd = *R_num_proc;
								param->tolerance = *R_tol;
								param->pourcentage = *R_percentage;
								param->beta = *R_alpha;
								param->I = *I;
								param->m = *R_ploidy;
								// param->missing_data = R_;
								param->seed = *R_seed;
								strcpy(param->input_file, *R_genotype_file);
								strcpy(param->input_file_Q, *R_input_file_Q);
								strcpy(param->output_file_Q, *R_output_file_Q);
								strcpy(param->output_file_F, *R_output_file_G);
								strcpy(param->output_file_Fst, *R_output_file_FST);
								strcpy(param->output_file_summary, *R_output_file_sum);
								strcpy(param->coord_input_file, *R_coord_file);
								strcpy(param->input_file_W, *R_input_file_W);

								// run
								sNMF(param, times);

								*all_ce = param->all_ce;
								*masked_ce = param->masked_ce;
								*R_seed = param->seed;
								*n = param->n;
								*L = param->L;

								// free memory
								free_param_snmf(param);
								free(param);

								// for random in R
								PutRNGstate();
}
