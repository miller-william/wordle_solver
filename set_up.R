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
all_possibles <- words

#simulate results of wordle function when answer is known
#this contains a bug in the case of multiple letters
#Current issue with this - when a guess contains an exact letter match
# if that letter appears elsewhere in the guess word, in wordle it will show as black (N)
# whereas in this code, it shows as orange

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

results <- simulate_results('tares','abbey')

#set up colours for printing results
cols <- c(
  "\033[48;5;249m", # grey
  "\033[48;5;226m", # yellow
  "\033[48;5;46m"   # green
)

#print colour results
colour_res <- function(word,results){
  for(i in 1:nchar(word)){
    if(substr(results,i,i)=='G'){cat(paste0(cols[3],' ',substr(word,i,i)))}
    else if(substr(results,i,i)=='O'){cat(paste0(cols[2],' ',substr(word,i,i)))}
    else{cat(paste0(cols[1],' ',substr(word,i,i)))}
  }
}

colour_res("tares",results)

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

#trim_word_list("tears",'NONGN',words)

