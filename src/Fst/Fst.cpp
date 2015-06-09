/*
Fst computation, file: Fst.cpp
Copyright (C) 2013 Kevin CAYE

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



#include "Fst.h"

#include <Eigen/Eigen>
typedef Eigen::Matrix < double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor > Matrixd;

void computeFst(double *Q, double *F, unsigned int n, unsigned int L, unsigned int K, unsigned int nc, double *Fst) {

	// Fst = 1 - sigma2_s / sigma2_T
	// sigma2_s = Sum_k( q_k * f_k * ( 1 - f_k ) )
	// sigma2_T = ( Sum_k( q_k * f_k ) * ( 1 - Sum_k( q_k * f_k ) ) )

	if (nc != 2 && nc != 3) {
		//Formula more complicated for any m TODO
		return;
	}

	Eigen::Map < Matrixd > QEigen(Q, n, K);
	Eigen::Map < Matrixd > FEigen(F, L * nc, K);
	Eigen::Map < Matrixd > FstEigen(Fst, L, 1);

	//Compute q
	Matrixd q(1, K);
	for (unsigned int k = 0; k < K; k++) {

		q(0,k) = QEigen.col(k).mean();

	}

	//compute f
	Matrixd f(L, K);
	if (nc == 2) {
		for (unsigned int l = 0; l < L; l++) {
			for (unsigned int k = 0; k < K; k++) {
				f(l, k) = FEigen(2 * l + 1, k);
			}
		}
	}
	else {
		// m =3
		for (unsigned int l = 0; l < L; l++) {
			for (unsigned int k = 0; k < K; k++) {
				f(l, k) = FEigen(3 * l + 2, k) + 0.5 * FEigen(3 * l + 1, k);
			}
		}

	}

	//compute sigma2_s
	Matrixd sigma2_s(L, 1);
	for (unsigned int l = 0; l < L; l++) {

		sigma2_s(l, 0) = (q * (f.row(l).array() * (1 - f.row(l).array())).matrix().transpose()).sum();


	}

	//compute sigma2_T
	Matrixd sigma2_T(L, 1);
	for (unsigned int l = 0; l < L; l++) {
		
		double aux = (q * f.row(l).transpose()).sum();
		sigma2_T(l, 0) = aux * ( 1 -aux ) ;


	}

	
	//Compute Fst
	FstEigen = (1 - sigma2_s.array() / sigma2_T.array());
	return;
}
