#include <iostream>
#include "spatialRegularizationTools.h"

#include <Eigen/Eigen>
#include <unsupported/Eigen/KroneckerProduct>
#include <math.h>
#include <cfloat>
#include <ctime>

using namespace std;

typedef Eigen::Matrix < double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor > Matrixd;

inline void heatKernel(Eigen::Map < Matrixd > & W, const Matrixd & Coord, unsigned int neighborNumber) {

	// Rmk : W is symetric so we store it in a upper triangular matrix
	unsigned int n = Coord.rows();
	W.setZero();

	Matrixd dist(n, n);
	Matrixd nonZero(n, n);//To count non zero coef in W
	dist.setZero();
	nonZero.setZero();

	// Compute all distances
	for (unsigned int i = 0; i < n; i++) {

		for (unsigned int j = i; j < n; j++) {

			//Using x and y
			dist(i, j) = (Coord(i, 0) - Coord(j, 0)) * (Coord(i, 0) - Coord(j, 0)) +
				(Coord(i, 1) - Coord(j, 1)) * (Coord(i, 1) - Coord(j, 1));

		}

	}
	
	dist = dist.selfadjointView<Eigen::Upper>();
	int auxi = 0, auxj = 0;

	// Compute W with only neirest neighbor
	for (unsigned int i = 0; i < n; i++) {

		for (unsigned int p = 0; p < neighborNumber + 1; p++) {
			dist.row(i).minCoeff(&auxi, &auxj);
			W(i, auxj) = dist(i, auxj);
			nonZero(i, auxj) = 1.0;
			W(auxj, i) = dist(i, auxj);//To be sure that W is symetric
			nonZero(auxj, i) = 1.0;
			dist(i, auxj) = DBL_MAX;
		}

	}

	//Remove diagonal one because they corespond to zero in W
	nonZero.diagonal().setZero();
	
	// Compute the average distance
	double sigma = W.sum() / nonZero.sum();
	
	double wOverSigma = 0.0;
	// Compute the weight
	for (unsigned int i = 0; i < n; i++) {
		for (unsigned int j = i; j < n ; j++) {
			if (W(i, j) != 0.0) {
				wOverSigma = W(i, j) / sigma;
				W(i, j) = exp(-wOverSigma * wOverSigma);
			}
		}
	}

	W = W.selfadjointView<Eigen::Upper>();

}

inline void heatKernel(Eigen::Map < Matrixd > & W, const Matrixd & Coord, double distance) {
  // Rmk : W is symetric so we store it in a upper triangular matrix
  unsigned int n = Coord.rows();
  W.setZero();

  Matrixd dist(n, n);
  Matrixd nonZero(n, n);//To count non zero coef in W
  dist.setZero();
  nonZero.setZero();

  // Compute all distances
  for (unsigned int i = 0; i < n; i++) {

    for (unsigned int j = i; j < n; j++) {

      //Using x and y
      dist(i, j) = (Coord(i, 0) - Coord(j, 0)) * (Coord(i, 0) - Coord(j, 0)) +
	(Coord(i, 1) - Coord(j, 1)) * (Coord(i, 1) - Coord(j, 1));

    }

  }
	
  distance *= dist.mean();
  

  // Compute W with only neighbor which are in the range
  for (unsigned int i = 0; i < n; i++) {

    for (unsigned int j = i; j < n; j++) {
      if( dist(i, j) < distance ) {
	
	W(i, j) = dist(i,j);
	nonZero( i, j) = 1.0;
	
      }
    }

  }



  //Remove diagonal one because they corespond to zero in W
  nonZero.diagonal().setZero();
	
  // Compute the average distance
  double sigma = W.sum() / nonZero.sum();
	
  double wOverSigma = 0.0;
  // Compute the weight
  for (unsigned int i = 0; i < n; i++) {
    for (unsigned int j = i; j < n ; j++) {
      if (W(i, j) != 0.0) {
  	wOverSigma = W(i, j) / sigma;
  	W(i, j) = exp(-wOverSigma * wOverSigma);
      }
    }
  }

  W = W.selfadjointView<Eigen::Upper>();

}

void create_weight_laplacian_matrix(double *W, double * L, double * coordMatrix, unsigned int n, double neighborProportion) {

	//We map coordMatrix and Gamma in an eigen matrix object
	Eigen::Map < Matrixd > coordMatrixEigen(coordMatrix, n, 2);

	Eigen::Map < Matrixd > LEigen(L, n, n);
	
	Eigen::Map < Matrixd > WEigen(W, n, n);

	// Create weight of the graph
	if (neighborProportion <= 0.0) {
	  
	  heatKernel(WEigen, coordMatrixEigen, -neighborProportion );
	  
	} else {
	  
	  heatKernel(WEigen, coordMatrixEigen, (unsigned int)floor(neighborProportion*n) );

	}
	

	//Compute matrix L the laplacian matrix of the graph : L = D - W
	//Remark = can be optimixed if we compute L outside
	LEigen.setZero();
	LEigen.diagonal() = WEigen * Eigen::VectorXd::Constant(n, 1.0);
	LEigen -= WEigen;
		
	return;
}

void create_laplacian_matrix(double *W, double * L, unsigned int n) {

	Eigen::Map < Matrixd > LEigen(L, n, n);
	
	Eigen::Map < Matrixd > WEigen(W, n, n);

	//Compute matrix L the laplacian matrix of the graph : L = D - W
	//Remark = can be optimixed if we compute L outside
	LEigen.setZero();
	LEigen.diagonal() = WEigen * Eigen::VectorXd::Constant(n, 1.0);
	LEigen -= WEigen;
		
	return;
}


double benchmark() {

	/* initialize random seed: */
	srand(time(NULL));

	int N = 7000;

	Eigen::MatrixXd m = Eigen::MatrixXd::Random(N, N);

	//std::cout << "det = " << m.determinant() << std::endl;

	//m = m.selfadjointView<Eigen::Upper>();

	//std::cout << "det = " << m.determinant() << std::endl;

	Eigen::VectorXd b = Eigen::VectorXd::Random(N);

	const clock_t begin_time = clock();
	Eigen::VectorXd x = m.colPivHouseholderQr().solve(b);
	std::cout << float(clock() - begin_time) / CLOCKS_PER_SEC << endl;

	std::cout << "error = " << (m*x - b).squaredNorm() << std::endl;

	return 0.0;

}

void unitTest(double *Q, double *Gamma, double *F, double * FtXt, unsigned int n, unsigned int Mp, unsigned int K, double beta, const Eigen::VectorXd & QtVec) {

	//test of Vec(Qt)	
	//plot to compare the two patrix
	cout << "QtVec = \n" << QtVec << endl;
	cout << "Q = \n";
	for (int j = 0; j < K*n; j++)
		cout << Q[j] << endl;

	
}

void compute_spatial_AtA(double *L, double *F, unsigned int n, unsigned int Mp, unsigned int K, double beta, double *AtA) {

	//Remark : double* matrices are stored as row major
	//Create Eigen wrapper
	Eigen::Map < Matrixd > FEigen(F, Mp, K);
	Eigen::Map < Matrixd > AtAEigen(AtA, n*K, n*K);
	Eigen::Map < Matrixd > LEigen(L, n, n);

	// AtA = ( Id_n (x) FtF + beta L (x) Id_K ) 
	// (x) is the kroneker product
	AtAEigen = Eigen::kroneckerProduct(Eigen::MatrixXd::Identity(n, n),
		FEigen.transpose() * FEigen).eval();
	AtAEigen += beta * Eigen::kroneckerProduct(LEigen,
		Eigen::MatrixXd::Identity(K, K)).eval();
	// For test : return same resultat that when using "classic als" with alpha = beta
	/*AtA += beta * Eigen::kroneckerProduct(Eigen::MatrixXd::Identity(n, n),
	Eigen::MatrixXd::Ones(K, K)).eval();*/

}

double update_spatial_Q(double *Q, double *L, double *F, double * FtXt, unsigned int n, unsigned int Mp, unsigned int K, double beta) {

	//Remark : double* matrices are stored as row major
	//Create Eigen wrapper
	Eigen::Map < Eigen::VectorXd >  QtVec(Q, n * K);
	Eigen::Map < Matrixd > LEigen(L, n, n);
	Eigen::Map < Matrixd > FtXtEigen(FtXt, K, n);
	Eigen::Map < Matrixd > FEigen(F, Mp, K);

	Matrixd AtA( n*K, n*K);

	// AtA = ( Id_n (x) FtF + beta L (x) Id_K ) 
	// (x) is the kroneker product


	AtA = Eigen::kroneckerProduct(Eigen::MatrixXd::Identity(n, n), 
		FEigen.transpose() * FEigen ).eval();
	AtA += beta * Eigen::kroneckerProduct(LEigen,
		Eigen::MatrixXd::Identity(K, K)).eval();
	// For test : return same resultat that when using "classic als" with alpha = beta
	/*AtA += beta * Eigen::kroneckerProduct(Eigen::MatrixXd::Identity(n, n),
		Eigen::MatrixXd::Ones(K, K)).eval();*/

	// Compute Vec(FtXt)
	//Remark : can be optimised : do not copy the matrix into a vector
	Eigen::VectorXd FtXtVec(K * n);
	for (int j = 0; j < FtXtEigen.cols(); j++) {
		FtXtVec.segment(j * K, K) = FtXtEigen.col(j);
	}

	// Vec(Qt) = AtA^-1 * Vec(tFXt)
	QtVec = AtA.ldlt().solve(FtXtVec);

	// projection on Q >= 0
	for (int j = 0; j<K*n; j++)
		Q[j] = fmax(Q[j], 0);

	// test
	//unitTest(Q, L, F, FtXt, n, Mp, K, beta, QtVec);

	// Compute return as ||Q||^2 very bad criteria 
	// TODO 
	//cout << "here spatial \n";
	return QtVec.squaredNorm();

}


void normalize_beta(double *beta, unsigned int n, unsigned int Mc, double * W) {

  Eigen::Map < Matrixd > WEigen(W, n, n);
  *beta *= n * Mc / ( 0.5 * WEigen.sum() );
    
}
