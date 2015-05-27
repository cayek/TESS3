#ifndef SPATIAL_REGULARIZATION_TOOLS_H
#define SPATIAL_REGULARIZATION_TOOLS_H


#ifdef __cplusplus
extern "C" {
#endif

	void create_weight_laplacian_matrix(double * W, double *L, double *coordMatrix, unsigned int n, double neighborProportion);
  void create_laplacian_matrix(double *W, double * L, unsigned int n);

	double update_spatial_Q(double *Q, double *L, double *F, double * FtXt, unsigned int n, unsigned int Mp, unsigned int K, double beta);

	void compute_spatial_AtA(double *L, double *F, unsigned int n, unsigned int Mp, unsigned int K, double beta, double *AtA);

        void normalize_beta(double *beta, unsigned int n, unsigned int Mc, double * W);

#ifdef __cplusplus
}
#endif

#endif
