
# Klasyczna funkcja coalesce
coalesce <- function(...) {
	apply(cbind(...), 1, function(x) {
		x[which(!is.na(x))[1]]
	})
}