#choose optimal guesses from remaining solution space
#optimal guess is one which has potential to 'rule out' the most possibilities. ie information gain
#e.g. guess which has most overlap with other solutions
#returns top 5 guesses

#output word most 'similar' to remaining words. This is based on minimum optimal string alignment distance from all other words
#see https://cran.r-project.org/web/packages/stringdist/stringdist.pdf

choose_word <- function(words){
  difference_matrix <- stringdist::stringdistmatrix(words$words, method = 'osa')
  differences <- colSums(as.matrix(difference_matrix))
  words$differences <- differences
  words <- words[order(words$differences),]
  return(head(words$words))
}

#best initial guesses
#choose_word(words)
# "sores" "sales" "sanes" "cares" "bares" "pares"

#automatic solver on test answer
#choose starting guess

simple_solver <- function(guess,test_answer,words){
  results <- ""
  guesses <- 1
  while(results != "GGGGG"){ 
    results <- simulate_results(word = guess,answer = test_answer)
    print(guess)
    words <- trim_word_list(input = guess, results = results, words)
    guesses <- guesses + 1
    guess <- choose_word(words)[1]
  }
  print(paste0('Solved in ',guesses, ' guesses'))
  return(guesses)
}

######### Final testing ############

#loop through each answer word -> takes a while
score <- ""
for(answer in answers[1:100]){
  score <- c(score,entropy_solver(guess="tares",test_answer=answer,words))
}
score <- score[-1]
performance <- data.frame(answers)
performance$score <- as.integer(score)

#if using 'tears' as the starting word, get average 4.91 guesses for dataset with an 88% success rate
#if using 'sores', as suggested by the model, get average of 5.23 guesses with an 84% success rate.
#if using 'cares' as the starting word, get average 5.98 with a 70% success rate
#if using 'cares' and not allowing dups on second guess, average of 5.8 guesses with a 75% success rate
#entropy solver: using 'tares', average of 4.69 with a 90% success rate.


#select a random word for testing
random_row <- sample(1:length(answers),1)
test_answer <- as.character(answers[random_row])
#test_answer <- "abbey"

simple_solver("tears","point",words)

################# LIVE SOLVER ###############

#Function for using on unknown solutions

live_simple_solver <- function(words){
  print(paste0("Enter all inputs as lower case"))
  guess <- readline(prompt="Enter initial guess: ")
  results <- toupper(readline(prompt="Enter initial result: "))
  while(results != "GGGGG"){ 
    #reduce solution space
    words <- trim_word_list(input = guess, results = results, words)
    guess <- choose_word(words)[1]
    user <- readline(prompt=paste0("Your guess is : ",guess,". Want a different guess? (y/n):"))
    if(user=="y"){
      #give second best guess instead
      guess <- choose_word(words)[2]
      print(paste0("New guess: ", guess))
    }
    results <- toupper(readline(prompt="Enter result: "))
  }
  paste0('You win!')
}

live_simple_solver(words)