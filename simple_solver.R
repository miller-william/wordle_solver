library(dplyr)
library(stringr)
library(stringdist)
library(stringi)

#read in list of words
#source words here: https://gist.github.com/cfreshman
words <- readLines('allowed.txt')
answers <- readLines('wordle-answers-alphabetical.txt')
words <- c(words,answers)
words <- data.frame(words)

#simulate results of wordle function when answer is known
#this contains a bug in the case of multiple letters, see notes at end

simulate_results <- function(word,answer){
  results <- ""
  for(i in 1:5){
    word_l <- substr(word,i,i)
    answer_l <- substr(answer,i,i)
    if(word_l==answer_l){results <- paste0(results,"G")}
    else if(word_l != answer_l & grepl(word_l, answer, fixed = TRUE)){results <- paste0(results,"O")}
    else{results <- paste0(results,"N")}
  }
  return(results)
}

#reduce solution space based on wordle input and results

trim_word_list <- function(input,results, words){
  for(i in 1:5){
    letter <- substr(input,i,i)
    #if orange, reduce list to words containing that letter AND remove words with that letter in that position
    if(substr(results,i,i) == "O"){
      words$check <- grepl(letter, words$words, fixed = TRUE)
      words <- filter(words, check==T)
      words$check <- ifelse(substr(words$words,i,i)==letter,T,F)
      words <- filter(words, check==F)
    }
    else if(substr(results,i,i) == "G"){
      words$check <- ifelse(substr(words$words,i,i)==letter,T,F)
      words <- filter(words, check==T)
    }
    else if(substr(results,i,i) == "N"){
      words$check <- grepl(letter, words$words, fixed = TRUE)
      words <- filter(words, check==F)
    }
    
  }
  output <- words
  return(output)
}

#choose optimal guesses from remaining solution space
#optimal guess is one which has potential to 'rule out' the most possibilities.
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
for(answer in answers){
  score <- c(score,simple_solver(guess="cares",test_answer=answer,words))
}
score <- score[-1]
performance <- data.frame(answers)
performance$score <- as.integer(score)

#if using 'tears' as the starting word, get average 4.91 guesses for dataset with an 88% success rate
#if using 'sores', as suggested by the model, get average of 5.23 guesses with an 84% success rate.
#if using 'cares' as the starting word, get average 5.98 with a 70% success rate
#if using 'cares' and not allowing dups on second guess, average of 5.8 guesses with a 75% success rate


#select a random word for testing
random_row <- sample(1:length(answers),1)
test_answer <- as.character(answers[random_row])
#test_answer <- "abbey"

simple_solver("cares","agape",words)

################# LIVE SOLVER ###############

#Function for using on unknown solutions
#Current issue with this - when a guess contains an exact letter match
# if that letter appears elsewhere in the guess word, it will show as black
# For this code to work, you need to enter the results for this duplicate letter as ORANGE

live_solver <- function(words){
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

live_solver(words)