source("entropy_solver.R")

#turn answers list to data frame
answers <- as.data.frame(answers)
names(answers) <- "words"

#gives best starting word as soare
entropy_choose(answers)

entropy_solver("soare","vaunt",answers)

# live solver
live_entropy_solver(answers)


