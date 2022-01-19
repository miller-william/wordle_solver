# Entropy functions

log2_alt <- function(x){
  if(x <= 0){return(0)}
  else{return(log2(x))}
} 

entropy <- function(dist){
  return(-(dist * log2_alt(dist)))
}

entropy_choose <- function(words){
  
  if(nrow(words)==1){return(as.character(words$words));break}
  
  #work out how many times each letter appears in each position in the answer set
  letters_in_pos <- data.frame()
  i <- 1
  for(letter in letters){
    for(pos in 1:5){
      letters_in_pos[i,pos] <- sum(substr(words$words,pos,pos) == letter)
    }
    i <- i + 1 
  }
  names(letters_in_pos) <- c("pos_1","pos_2","pos_3","pos_4","pos_5")
  row.names(letters_in_pos) <- letters
  
  i <- 1
  prev_green_letters <- ""
  green_score <- 0
  orange_score <- 0
  
  #generate prev green letters word e.g. #a###
  for(i in 1:5){
    if(length(unique(substr(words$words,i,i)))==1){
      prev_green_letters[i] <- unique(substr(words$words,i,i))
    }
    else{prev_green_letters[i] <- "#"}
  }

  #currently unknown positions
  unknown <- which(unlist(str_split(prev_green_letters,""))=="#")
  
  #generate known letters based on solution space (e.g. letters in every word)
  prev_orange_letters <- ""
  for(char in letters){
    if(sum(grepl(char,words$words)) == nrow(words)){
      prev_orange_letters <- c(prev_orange_letters,char)
    }
  }
  
  best_word <- ""
  best_diff_entropy <- 0
  
  for(word in all_possibles$words){
    #print(word)
    diff_entropy <- 0
    seen_chars <- ""
    i <- 1
    for(char in strsplit(word,"")[[1]]){
      #if we already know about this letter, it adds little value so set score to zero
      if(char == prev_green_letters[i]){
        green_score <- 0
      }
      else{green_score <- letters_in_pos[char,i]}
      if(!(char %in% seen_chars) & !(char %in% prev_orange_letters)){
        #only if we haven't already had this orange - that doesn't give us new info.
        orange_score <- sum(letters_in_pos[char,unknown]) - green_score
        seen_chars <- c(seen_chars,char)
      }
      
      else{orange_score <- 0}
      
      grey_score <- 5*nrow(words) - green_score - orange_score
      
      dist <- c(green_score, orange_score, grey_score)
      #print(dist)
      dist <- dist/sum(dist)
      diff_entropy <- diff_entropy + sum(sapply(dist,FUN=entropy))
      #print(diff_entropy)
      i <- i +1
      
    }
    if(diff_entropy > best_diff_entropy){
      best_diff_entropy <- diff_entropy
      best_word <- word
      #print(paste0("new best word is ",best_word))
    }
    
  }
return(best_word)
}

entropy_choose(words)
#gives best starting word as soare

#guess <- 'soare'
#test_answer <- "blobby"

entropy_solver <- function(guess,test_answer,words){
  results <- ""
  guesses <- 0
  while(results != "GGGGG"){ 
    results <- simulate_results(word = guess,answer = test_answer)
    print(guess)
    words <- trim_word_list(input = guess, results = results, words)
    guesses <- guesses + 1
    guess <- entropy_choose(words)
  }
  print(paste0('Solved in ',guesses, ' guesses'))
  return(guesses)
}

entropy_solver("soare","bobby",words)

# live solver

live_entropy_solver <- function(words){
  print(paste0("Enter all inputs as lower case"))
  guess <- readline(prompt="Enter initial guess: ")
  results <- toupper(readline(prompt="Enter initial result: "))
  while(results != "GGGGG"){ 
    #reduce solution space
    words <- trim_word_list(input = guess, results = results, words)
    guess <- entropy_choose(words)
    print(paste0("Your guess is : ",guess))
    results <- toupper(readline(prompt="Enter result: "))
  }
  paste0('You win!')
}

live_entropy_solver(words)

