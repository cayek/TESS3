/*
    sNMF, file: print_snmf.c
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


#include "print_snmf.h"
#include "sNMF.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// print_licence_snmf

void print_licence_snmf() 
{
        printf("TESS3 Copyright (C) 2015 K. Caye\n"
    "This program is free software: you can redistribute it and/or modify\n"
    "it under the terms of the GNU General Public License as published by\n"
    "the Free Software Foundation, either version 3 of the License, or\n"
    "(at your option) any later version.\n"

    "This program is distributed in the hope that it will be useful,\n"
    "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
    "GNU General Public License for more details.\n"

    "You should have received a copy of the GNU General Public License\n"
    "along with this program.  If not, see <http://www.gnu.org/licenses/>.\n");

}

// print_head_licence_snmf

void print_head_licence_snmf() 
{
    printf("TESS3 Copyright (C) 2015 K. Caye\n"
    "This program comes with ABSOLUTELY NO WARRANTY; for details type './sNMF -l'.\n"
    "This is free software, and you are welcome to redistribute it\n"
    "under certain conditions; type './TESS3 -l' for details.\n\n");

}

// print_head_snmf

void print_head_snmf() 
{
        print_head_licence_snmf();
        printf("****                      TESS3 version 1.0                                     *****\n"
               "****   K. Caye, T. Deist, H. Martins, O. Michel, O. Francois         *****\n"
               "****                    Please cite our paper !                                *****\n"
               "****   Information at ????   *****\n\n");
}

// print_help_snmf

void print_help_snmf()
{
   printf("\nHELP: ./TESS3 options \n\n"
         "mandatory:\n"
         "        -x genotype_file      -- genotype file (in .geno format)\n"
         "        -K K                  -- number K of ancestral populations\n"
		 
		 "        -r coordinates_file   -- coordinates input file\n"
		 " OR \n"
		 "        -W edge_weight_file  -- edge weight matrix of the graph input file\n"
		 
         "optional:\n"
         "        -h                    -- help\n"
         "        -a alpha              -- normalized regularization parameter       (default: 0.001)\n"
         "        -q output_Q           -- individual admixture file      (default: genotype_file.K.Q)\n"
         "        -g output_G           -- ancestral frequencies file     (default: genotype_file.K.G)\n"
		 "        -f					-- Fst file                       (default: genotype_file.F.Fst)\n"
         "        -c perc               -- cross-entropy with 'perc'                         \n"
         "                              of masked genotypes               (default: 0.05)\n"
         "        -e tol                -- tolerance error                (default: 0.0000001)\n"
         "        -i iterations         -- number max of iterations       (default: 200)\n"
         "        -I nb_SNPs            -- number of SNPs used to init Q  (default: min(10000,L/10)\n"
         "        -Q input_Q            -- individual admixture initialisation file\n" 
         "        -s seed               -- seed random init               (default: random)\n"
         "        -m ploidy             -- 1 if haploid, 2 if diploid     (default: 2)\n"
         "        -p num_proc           -- number of processes (CPU)      (default: 1)\n"
        );
}

// print_summary_snmf

void print_summary_snmf (sNMF_param param)
{

   printf("summary of the options:\n\n"
         "        -n (number of individuals)             %d\n"
         "        -L (number of loci)                    %d\n"
         "        -K (number of ancestral pops)          %d\n"
         "        -x (input file)                        %s\n"
         "        -q (individual admixture file)         %s\n"
         "        -g (ancestral frequencies file)        %s\n"
		 "        -f (Fst file)        %s\n"
		 "        -y (summary results file)        %s\n"
         "        -i (number max of iterations)          %d\n"
		 "        -a (normalized regularization parameter)          %G\n"
         "        -s (seed random init)                  %llu\n"
         "        -e (tolerance error)                   %G\n"
         "        -p (number of processes)               %d\n",
	 param->n, param->L, param->K, param->input_file, param->output_file_Q,
	 param->output_file_F, param->output_file_Fst, param->output_file_summary, param->maxiter, param->beta,
	 (long long)(param->seed), param->tolerance, param->num_thrd);
        
        if (param->pourcentage != 0)
                printf("        -c (cross-Entropy criterion)           %G\n", 
			param->pourcentage);
	if (strcmp(param->coord_input_file, "")) {
	  printf("        -r (coordinates input file)                        %s\n", param->coord_input_file);
}
		if (strcmp(param->input_file_W, ""))
			printf("        -W (edge weight input file)                        %s\n", param->input_file_W);
        if (strcmp(param->input_file_Q,""))
                 printf("        -Q (admixture initialisation file)     %s\n", param->input_file_Q);
        else if (param->I)
                printf("        -I (number of SNPs used to init Q)     %d\n", param->I);
        if (param->m == 1)
                printf("        - haploid\n\n");
        else if (param->m == 2)
                printf("        - diploid\n\n");
        else
                printf("        - %d-ploid\n\n",param->m);


}


void write_summary_results_snmf(char *output_file_summary, double like, double all_ce, double masked_ce) {

	FILE *m_File = NULL;

	// open file
	m_File = fopen_write(output_file_summary);

	fprintf(m_File, "Least-square error: %f\n", like);
	
	fprintf(m_File, "Cross-Entropy (all data): %f\n", all_ce);

	fprintf(m_File, "Cross-Entropy (masked data): %f\n", masked_ce);

}
