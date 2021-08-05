# Simple example showing how to subset data before running (mc)lapply

# Get data
A <- LETTERS
n <- length(A)

# Test operation without splitting input into groups beforehand
B <- sort(unlist(lapply(1:n, function(x) A[x])))
identical(A, B)

# Subset into groups using split
A.split <- split(1:n, rep_len(1:w, length(1:n)))

# Repeat operation with groups using a single core
B <- sort(unlist(lapply(A.split, function(x) A[x]), use.names = F))
identical(A, B)

# Repeat operation with groups using multiple cores
B <- sort(unlist(mclapply(A.split, function(x) A[x]), use.names = F))
identical(A, B)

# If multi-core use had a high computational overhead relative to the 
# computational complexity of the operation being performed, then the
# last approach should be the most efficient.
