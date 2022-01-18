# Alternate choose_word function which restricts the solver from selecting words with duplicate characters in on the first two guesses.
# This reduces the performance of the solver.

choose_word <- function(words,guess_no){
  difference_matrix <- stringdist::stringdistmatrix(words$words, method = 'osa')
  differences <- colSums(as.matrix(difference_matrix))
  words$differences <- differences
  words$dups <- apply(t(as.data.frame(strsplit(words$words,""))),1,FUN=anyDuplicated)
  words_dedup <- filter(words,dups==0)
  if(guess_no < 3 & nrow(words_dedup)>5){
    words_dedup <- words_dedup[order(words_dedup$differences),]
    return(head(words_dedup$words))
  }
  else{
    words <- words[order(words$differences),]
    return(head(words$words))
  }
}