#' TODO
#'
#'
#' TODO
#'
#' @return TODO
#'
#' @examples
#' TODO
#
#' @export
heat.kernel.weight <- function(coord,sigma) {
  W = matrix(0,nrow(coord),nrow(coord))
  for(i in 1:nrow(coord)) {
    for(j in 1:nrow(coord)){
      W[i,j] = sqrt(sum((coord[i,]-coord[j,])^2))
    }
  }
  if(is.null(sigma)) {
    sigma = 0.05*mean(W)
    cat("sigma = ",sigma)
  }
  W = apply(W, c(1,2), function(d){exp(-d^2/sigma^2)})
  return(W)
}

#' TODO
#'
#'
#' TODO
#'
#' @return TODO
#'
#' @examples
#' TODO
#
#' @export
graph.laplacian <- function(W) {
  D = diag(apply(W,1,sum))
  return(D - W)
}

#' Compute a sigma with similitude matrix
#'
#'
#' TODO
#'
#' @return TODO
#'
#' @examples
#' TODO
#
#' @export
compute.sigma <- function(coord, sim.matrix) {

  B = -log(sim.matrix)
  dim(B) = c(nrow(B) * ncol(B))


  dist2 = matrix(0,nrow(coord),nrow(coord))
  for(i in 1:nrow(coord)) {
    for(j in 1:nrow(coord)){
      dist2[i,j] = sum((coord[i,]-coord[j,])^2)
    }
  }

  dim(dist2) = c(nrow(dist2)*ncol(dist2),1)
  a = solve(crossprod(dist2,dist2),crossprod(dist2,B))

  sigma = sqrt(1/a)

  return(sigma)

}

