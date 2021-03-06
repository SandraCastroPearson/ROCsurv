#' Check Proportional Hazards Based Curve
#'
#' @param time passed from ROCsurv.
#' @param event passed from ROCsurv.
#' @param group passed from ROCsurv.
#' @param silent passed from ROCsurv.
#' @param abtwc passed from ROCsurv.
#' @param xlab passed from ROCsurv.
#' @param ylab passed from ROCsurv.
#' @param main passed from ROCsurv.
#'
#' @return A plot of the ROC curve and an ROCsurv object containing:
#' \itemize{
#'  \item A survfit object for the treatment group.
#'  \item A survfit object for the control group.
#'  \item The area under the curve for the ROC in the given plot.
#' }
#'
#' @importFrom graphics segments
#' @importFrom graphics rect
#' @importFrom stats na.omit
#' @import survival
#' @importFrom stats cor
#' @importFrom pathmapping CreateMap
#' @importFrom utils capture.output
#' @importFrom stats coef
#'
#' @keywords internal
#' @noRd

ROCandPHM <- function(time, event, group, silent, abtwc, xlab, ylab, main, cex.axis,
                      cex.lab, lty, label.inset, label.cex, lwd){

  coxfit <- coxph(Surv(time, event) ~ group, ties = "breslow")
  KMres <- getKMtab(time, event, group)
  skm <- KMres[[1]]
  forplot = get4plot(skm)

  forplot <- cbind(forplot, cy=forplot[,1]^exp(coef(coxfit)))
  rho <- cor(forplot[,c(2,4)])
  resid <-  forplot[,4] - forplot[,2]
  SSR <- sum(resid^2)
  if (abtwc == TRUE){
      invisible(capture.output(out <- CreateMap(forplot[,c(1,2)],
                                                forplot[,c(1,4)],
                                            plotgrid=F, verbose=F, insertopposites=F)))
      areaBTWcurves <- out$deviation
  }
  u = unique(c(seq(min(forplot[,1]), 1, 0.001), 1))
  if(silent==FALSE){
    plot(NULL, type="n", las=1,
         xlim=c(0,1), ylim = c(0, 1), #to make tight axis: xaxs="i", yaxs="i"
         xlab=xlab, ylab=ylab, main=main, cex.axis = cex.axis, cex.lab = cex.lab)
    lines(u, u^exp(coef(coxfit)), col = "black", lty=lty[2], lwd = lwd)
    lines(forplot[,1], forplot[,2], col="black", lty=lty[1], lwd = lwd)
    abline(c(0,1), col = "darkgrey", lty=1, lwd = lwd-0.25)

    legend("topleft", c("KM-Based Curve", "Cox-Based Curve"), lty = lty,
           inset=label.inset, cex=label.cex, bg = "white", bty='n', seg.len = 0.8,
           x.intersp=0.9, y.intersp = 0.85, lwd = lwd)
    }

  if (abtwc == TRUE){
    res <- list(SSR = SSR, rho = rho, areaBTWcurves = areaBTWcurves)
    } else {res <- list(SSR = SSR, rho = rho)}

  return(res)

}

