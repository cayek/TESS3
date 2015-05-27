/*
   sNMF, file: als_Q.c
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


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "als_Q.h"
#include "../matrix/matrix.h"
#include "../matrix/rand.h"
#include "../matrix/data.h"
#include "../matrix/inverse.h"
#include "../matrix/normalize.h"
#include "../io/print_bar.h"
#include "../bituint/bituint.h"
#include "../bituint/calc_bituint.h"
#include "../spatialRegularizationTools/spatialRegularizationTools.h"

#ifndef WIN32
#include "thread_Q.h"
#include "thread_snmf.h"
#endif

// update_nnlsm_Q

double update_nnlsm_Q(sNMF_param param, Nnlsm_param n_param)
{
	int i, k;
	int K = param->K;
	int N = param->n;
	double *Y = param->Y;
	double *Q = param->Q;

	double res;

	// compute temp1 = t(F) * F + alpha
	tBB_alpha(param->temp1, param->F, param->alpha, param->Mc, param->K,
		param->num_thrd);

	// compute temp3 = t(F) t(X)
	tBtX(param->temp3, param->X, param->F, param->K, param->Mp,
		param->Mc, N, param->num_thrd);

	// solve tempQ >= 0, to minimize ||temp1 * tempQ - temp3||_F
	nnlsm_blockpivot(param->temp1, param->temp3, N, param->K,
		param->tempQ, param->Y, n_param);

	// update Q
	for (i = 0; i < N; i++)
		for (k = 0; k < K; k++)
			Q[i*K + k] = param->tempQ[k*N + i];

	// new output criteria, based on Kim and Park criterion
	res = 0.0;
	for (i = 0; i < N; i++) {
		for (k = 0; k < K; k++) {
			if (Q[i * K + k] > 0 || Y[k * N + i] < 0) {
				
				res += Y[k * N + i] * Y[k * N + i];
			}
		}
	}

	return sqrt(res);
}



double update_nnlsm_spatial_Q(sNMF_param param, Nnlsm_param n_param)
{
  int i, k, j;
	int K = param->K;
	int N = param->n;
	double *Y = param->Y;
	double *Q = param->Q;

	double res;

	//To optimize : can be do outside of this function
	double * AtA = (double *)calloc(N*K * N*K, sizeof(double));
	double * FtXtVec = (double *)calloc(N*K, sizeof(double));

	// compute temp1 = AtA
	compute_spatial_AtA(param->Laplacian, param->F, param->n, param->Mc, param->K, param->beta, AtA);

	// compute temp3 = Vec( t(F) t(X) )
	tBtX(param->temp3, param->X, param->F, param->K, param->Mp,
		param->Mc, N, param->num_thrd);
	for (i = 0; i < K; i++) {
	  for ( j = 0; j < N; j++) {
			FtXtVec[j * K + i] = param->temp3[i * N + j];
		}
	}


	// solve tempQ >= 0, to minimize ||A * vec(Qt) - vec(Xt)||_F
	nnlsm_blockpivot(AtA, FtXtVec, 1, K*N,
		Q, param->Y, n_param);

	// new output criteria, based on Kim and Park criterion
	// Do not really work !!  to see
	res = 0.0;
	for (i = 0; i < N; i++){
		for (k = 0; k < K; k++) {
			if (Q[i * K + k] > 0 || Y[i * K + k] < 0) {
				res += Y[i * K + k] * Y[i * K + k];
			}
		}
	}



	return sqrt(res);
}


// normalize_Q

void normalize_Q(double *Q, int N, int K)
{
	normalize_lines(Q, N, K);
}

// udpate_Q (not used) TODO / decreprated


void update_Q(sNMF_param param) {

	double *Q = param->Q;
	double *F = param->F;
	bituint *X = param->X;
	int N = param->n;
	int M = param->L;
	int K = param->K;
	int nc = param->nc;
	int Mp = param->Mp;
	double alpha = param->alpha;

	int i, j, k1, k2;
	double *temp1 = param->temp1;
	double *temp2 = param->tempQ;
	double *temp3 = param->temp3;

	int Mc = nc*M;
	int Md = Mc / SIZEUINT;
	int Mm = Mc % SIZEUINT;
	int jd, jm;
	bituint value;


	// compute temp1 = t(F) * F + alpha
	tBB_alpha(temp1, F, alpha, Mc, K,
		param->num_thrd);

	//computation of temp2 = inverse(temp1)
	fast_inverse(temp1, K, temp2);

	zeros(temp3, K*N);
	//computation of temp3 = t(F)*t(X)
	for (jd = 0; jd < Md; jd++) {
		for (i = 0; i < N; i++) {
			value = X[i*Mp + jd];
			for (jm = 0; jm < SIZEUINT; jm++) {
				if (value % 2) {
					for (k1 = 0; k1 < K; k1++)
						temp3[k1*N + i] += F[(jd*SIZEUINT + jm)*K + k1];
				}
				value >>= 1;
			}
		}
	}
	for (i = 0; i < N; i++) {
		value = X[i*Mp + Md];
		for (jm = 0; jm < Mm; jm++) {
			if (value % 2) {
				for (k1 = 0; k1 < K; k1++)
					temp3[k1*N + i] += F[(Md*SIZEUINT + jm)*K + k1];
			}
			value >>= 1;
		}
	}

	// t(Q) = temp2 * temp3
	zeros(Q, K*N);
	for (k1 = 0; k1 < K; k1++) {
		for (k2 = 0; k2 < K; k2++) {
			for (i = 0; i < N; i++) {
				Q[i*K + k2] += temp2[k2*K + k1] * temp3[k1*N + i];
			}
		}
	}

	// Q[Q < 0] = 0.0;
	for (j = 0; j < N; j++)
		for (i = 0; i < K; i++)
			Q[j*K + i] = fmax(Q[j*K + i], 0);

	//printf("here classic \n");

}


