/*
   sNMF, file: als.c
   Copyright (C) 2013 François Mathieu, Eric Frichot

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "als.h"
#include "../matrix/matrix.h"
#include "../matrix/rand.h"
#include "../matrix/data.h"
#include "../matrix/inverse.h"
#include "../matrix/normalize.h"
#include "../io/print_bar.h"
#include "als_Q.h"
#include "als_F.h"
#include "sNMF.h"
#include "../bituint/bituint.h"
#include "../nnlsm/nnlsm.h"
#include "../bituint/calc_bituint.h"
#include "../spatialRegularizationTools/spatialRegularizationTools.h"
#include "criteria.h"
// ALS


void ALS(sNMF_param param, double *times)
{
	double prec2 = 1.0, sum2 = 0.0;
	int k, i, j, l, c;
	Nnlsm_param n_param;
	Nnlsm_param n_param_spatial;
	int N = param->n;
	int M = param->L;
	int K = param->K;
	int nc = param->nc;
	double *Q = param->Q;
	double *F = param->F;

	clock_t start, end;

	//Initialisation of Q, prec and bar
	//rand_matrix_double(Q, N, K);
	normalize_lines(param->Q, N, K);
	init_bar(&i,&j);

	// allocate memory for the all algorithm
	n_param = allocate_nnlsm(N, K);
	n_param_spatial = allocate_nnlsm(1, N * K);


	for (k = 0; k < param->maxiter; k++) {
		print_bar(&i,&j, param->maxiter);
#ifdef USING_R
		// tout est dans le titre de la fonction,
		// check si l'utilisateur a essayé d'interrompre le programme
		R_CheckUserInterrupt();
#endif

		start = clock();
		// update F
		update_F(param);
		// check numerical issues
		if (isnan(param->F[0])) {
			printf("ALS: Internal Error, F is NaN.\n");
			exit(1);
		}
		normalize_F(param->F,M, param->nc, K);


		// update Q
		if (param->W == NULL) {
			if (param->nnlsm_Q) {
				sum2 = update_nnlsm_Q(param, n_param);
			}
			else {
				update_Q(param);
				sum2 = prec2 + prec2;// stoping criteria to improve
			}
		}
		else {

			if (param->nnlsm_Q) {
				sum2 = update_nnlsm_spatial_Q(param, n_param_spatial);
			}
			else {

				tBtX(param->temp3, param->X, param->F, param->K, param->Mp, param->Mc, N, param->num_thrd);
				sum2 = update_spatial_Q(param->Q, param->Laplacian, param->F, param->temp3, param->n, param->Mc, param->K, param->beta);
				sum2 = prec2 + prec2;// stoping criteria to improve
			}

		}
		// check numerical issues
		if (isnan(param->Q[0])) {
			printf("ALS: Internal Error, Q is NaN.\n");
			exit(1);
		}
		normalize_Q(param->Q,N,K);

		if (param->W != NULL) {
			// stopping criteria !! stopping criteria over derivative implemented inside update_nnlsm_spatial_Q don't work
			// Is it true for our problem?
			sum2 = least_square(param);

		}
		end = clock();
		times[k] = ((double) (end - start)) / CLOCKS_PER_SEC;
		
		// stopping criteria
		if (k > 15 && fabs(prec2 - sum2) < param->tolerance) {
			break;
		}
		prec2 = sum2;
	}
	final_bar();

	printf("Number of iterations: %d\n",k);
	normalize_F(param->F, M, param->nc, K);

	// to avoid numerical issues in crossEntropy calculation
	for(l = 0; l < N*K; l++) {
		if (fabs(Q[l]) < 0.0001)
			Q[l] = 0.0001;
		if (fabs(1-Q[l]) < 0.0001)
			Q[l] = 1-0.0001;
	}

	for(j = 0; j < M; j++) {
		for (c = 0; c < nc; c++) {
			for(k = 0; k < K; k++) {
				if (fabs(F[(nc*j+c)*K+k]) < 0.0001)
					F[(nc*j+c)*K+k] = 0.0001;
				if (fabs(1-F[(nc*j+c)*K+k]) < 0.0001)
					F[(nc*j+c)*K+k] = 1-0.0001;
			}
		}
	}

	normalize_Q(Q,N,K);

	// free memory
	free_nnlsm(n_param);
	free(n_param);
	free_nnlsm(n_param_spatial);
	free(n_param_spatial);
}
