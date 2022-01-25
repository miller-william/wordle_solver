######### Final testing ############

#loop through each answer word -> takes a while
score <- ""
for(answer in answers$words){
  score <- c(score,entropy_solver(guess="soare",test_answer=answer,answers))
}
score <- score[-1]
performance <- data.frame(answers[])
performance$score <- as.integer(score)

#avg number of guesses taken
mean(performance$score)
#percentage failed
100*sum((performance$score>6))/nrow(answers)

write.csv(performance,file="performance_entropy_cheat")

library(ggplot2)
data <- as.data.frame(summary(as.factor(performance$score)))
names(data) <- 'count'
data$guesses <- row.names(data)

ggplot(data, aes(x=count,y=guesses)) + geom_bar(stat="identity") + coord_flip()