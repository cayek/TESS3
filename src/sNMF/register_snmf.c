/*
	NMF, file: register_snmf.c
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
#include "register_snmf.h"
#include "print_snmf.h"
#include "error_snmf.h"
#include "../io/io_tools.h"

// analyse_param_snmf

void analyse_param_snmf(int argc, char *argv[], sNMF_param param)
{
	int i;
	int g_data = -1;
	int c_data = -1;
	char *tmp_file;
	char tmp[512];
	int g_c = 0;
	int g_m = 0;

	for (i = 1; i < argc; i++) {
		if (argv[i][0] == '-') {
			switch (argv[i][1]) {
			case 'K':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "K (number of clusters)", 0);
				param->K = atoi(argv[i]);
				strcpy(tmp, argv[i]);
				break;
			case 's':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "s (seed number)", 0);
				param->seed = atoll(argv[i]);
				break;
			case 'm':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "m (number of alleles)", 0);
				param->m = atoi(argv[i]);
				g_m = 1;
				break;
			case 'a':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "alpha (normalized regularization parameter)", 0);
				param->beta = (double)atof(argv[i]);
				if (param->beta < 0) {
					param->beta = 0;
				}
				break;
			case 'h':   // global
				print_help_snmf();
				exit(1);
				break;
			case 'l':   // global
				print_licence_snmf();
				exit(1);
				break;
			case 'e':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "e (tolerance error in the algorithm)", 0);
				param->tolerance = (double)atof(argv[i]);
				if (param->tolerance < 0) {
					param->tolerance = 0;
				}
				break;
			case 'c':
				i++;
				if (argc == i || argv[i][0] == '-') {
					param->pourcentage = 0.05;
					i--;
				}
				else  {
					param->pourcentage = (double)atof(argv[i]);
				}
				g_c = 1;
				break;
			case 'i':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "i (number of iterations)", 0);
				param->maxiter = atoi(argv[i]);
				break;
			case 'I':
				i++;
				if (argc == i || argv[i][0] == '-') {
					param->I = -1;
					i--;
				}
				else
					param->I = (int)atoi(argv[i]);
				break;
			case 'x':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "x (genotype file)", 0);
				g_data = 0;
				strcpy(param->input_file, argv[i]);
				break;
			case 'r':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "r (coordinates file)", 0);
				c_data = 0;
				strcpy(param->coord_input_file, argv[i]);
				break;
			case 'q':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "q (individual admixture coefficients file)", 0);
				strcpy(param->output_file_Q, argv[i]);
				break;
			case 'Q':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "Q (admixture coefficients initialization file)", 0);
				strcpy(param->input_file_Q, argv[i]);
				break;
			case 'g':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "g (ancestral genotype frequencies file)", 0);
				strcpy(param->output_file_F, argv[i]);
				break;
			case 'p':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "p (number of processes)", 0);
				param->num_thrd = atoi(argv[i]);
				break;
			case 'k':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "k (1 to use nnlsm algo)", 0);
				param->nnlsm_Q = atoi(argv[i]);
				break;
			case 'W':
				i++;
				if (argc == i || argv[i][0] == '-')
					print_error_nmf("cmd", "W (W graph weigth matrix file)", 0);
				c_data = 0;
				strcpy(param->input_file_W, argv[i]);
				break;
			case 'z':
				i++;
				if (argc == i )
					print_error_nmf("cmd", "z (percentage of neighbor in [0,1] or if negative size of neighborhood normilized by the average distance between nodes)", 0);
				param->neighborProportion = (double)atof(argv[i]);
				break;
			default:    print_error_nmf("basic", NULL, 0);
			}
		}
		else {
			print_error_nmf("basic", NULL, 0);
		}
	}

	if (g_data == -1)
		print_error_nmf("option", "-x genotype_file", 0);

	if (c_data == -1)
		print_error_nmf("option", "-r coordinate_file or -W graph_weight_file ", 0);

	if (param->K <= 0)
		print_error_nmf("missing", NULL, 0);

	if (param->num_thrd <= 0)
		print_error_nmf("missing", NULL, 0);

	if (g_m && param->m <= 0)
		print_error_nmf("missing", NULL, 0);

	if (param->maxiter <= 0)
		print_error_nmf("missing", NULL, 0);

	if (g_c && (param->pourcentage <= 0 || param->pourcentage >= 1))
		print_error_nmf("missing", NULL, 0);

	if (param->neighborProportion <= 0 || param->neighborProportion >= 1)
		print_error_nmf("missing", NULL, 0);



	// write output file name
	tmp_file = remove_ext(param->input_file, '.', '/');
	if (!strcmp(param->output_file_Q, "")) {
		strcpy(param->output_file_Q, tmp_file);
		strcat(param->output_file_Q, ".");
		strcat(param->output_file_Q, tmp);
		strcat(param->output_file_Q, ".Q");
	}
	if (!strcmp(param->output_file_F, "")) {
		strcpy(param->output_file_F, tmp_file);
		strcat(param->output_file_F, ".");
		strcat(param->output_file_F, tmp);
		strcat(param->output_file_F, ".G");
	}
	free(tmp_file);
}

// init_param_snmf

void init_param_snmf(sNMF_param param)
{
	// default values 
	param->K = 0;
	param->beta = 0.001;
	param->alpha = 0.0;
	param->maxiter = 200;
	param->num_thrd = 1;
	param->tolerance = 0.0000001;
	strcpy(param->output_file_F, "");
	strcpy(param->output_file_Q, "");
	strcpy(param->input_file_Q, "");
	strcpy(param->input_file_W, "");
	strcpy(param->coord_input_file, "");
	param->seed = -1;
	param->m = 0;
	param->pourcentage = 0.0;
	param->I = 0;
	param->all_ce = 0;
	param->masked_ce = 0;
	param->nnlsm_Q = 1;
	param->neighborProportion = 0.05;
}

// free_param_snmf 

void free_param_snmf(sNMF_param param)
{
	// Q
	if (param->Q)
		free(param->Q);
	// F
	if (param->F)
		free(param->F);
	// X
	if (param->X)
		free(param->X);
	// Xi
	if (param->Xi)
		free(param->Xi);
	// temp1
	if (param->temp1)
		free(param->temp1);
	// tempQ
	if (param->tempQ)
		free(param->tempQ);
	// temp3
	if (param->temp3)
		free(param->temp3);
	// Y
	if (param->Y)
		free(param->Y);

	// CoordMatrix
	if (param->coordMatrix)
		free(param->coordMatrix);

	//Laplacian
	if (param->Laplacian)
		free(param->Laplacian);

	//W
	if (param->W)
		free(param->W);
}

