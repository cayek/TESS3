/**
 * @addtogroup als_Q
 * @ingroup sNMF
 * @{
 * @file als_Q.h
 *
 * @brief set of functions to compute update Q in als algorithm
 */


#ifndef ALS_Q_H
#define ALS_Q_H

#include "../bituint/bituint.h"
#include "../nnlsm/nnlsm.h"
#include "sNMF.h"

/** @brief Update Q (not used, out of date)
 *
 * @param param	sNMF parameter structure
 */
void update_Q(sNMF_param param);


/** @brief Update Q with non-negative least square method 
 *
 * @param param	sNMF parameter structure 
 * @param n_param	NNLSM parameter structure 
 */
double update_nnlsm_Q(sNMF_param param, Nnlsm_param n_param);

/** @brief Update Q with non-negative least square method
*
* @param param	sNMF parameter structure
* @param n_param	NNLSM parameter structure
*/
double update_nnlsm_spatial_Q(sNMF_param param, Nnlsm_param n_param);

/** @brief normalize Q
 * 
 * @param Q 	ancestral frequencies (of size NxK)
 * @param N 	number of individuals
 * @param K	number of clusters
 */
void normalize_Q(double *Q, int N, int K);

#endif // ALS_Q_H

/** @} */
