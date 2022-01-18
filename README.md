# wordle_solver

This is my attempt at building a simple wordle solver in R.

[wordle](https://www.powerlanguage.co.uk/wordle/)

## simple_solver

This solver uses the `stringdist` [package](https://cran.r-project.org/web/packages/stringdist/stringdist.pdf) in R to choose new guesses. 

Reducing the solution space based on wordle results in the format 'GNGOO' (where G is a green result corresponding to the letter in the first and third positions, N corresponds to a nil result and O is orange) is straightforward.

Choosing an optimal guess is less trivial. This solver takes a string distance approach. This is based on the (not particularly well thought-through) logic that we want to maximise the information gain of each guess. And the similarity of a given word to all other words in the solution space is a proxy for this. 

The total string distance for a word in the possible solution space is calculated by summing over the string distance between that word and every other possible word.

The word from the solution space with the minimum total string distance is suggested as the next guess.

The simple_solver contains a simulation tool (function: `simple_solver`) which can be used to simulate the solvers guesses for a given starting guess and answer. 

It also contains a live solver (function: `live_solver`), where the user can manually input results into the R console and receive suggested guesses without the function 'knowing' the answer.

## Performance

We can test performance by running the solver on every answer in the wordle answer list and recording how many guesses it took.

If using 'tears' as the starting word, the solver averaged 4.91 guesses for dataset with an 88% success rate. 
If using 'sores' (best starting guess as suggested by the model), the solver averaged 5.23 guesses with an 84% success rate.

## Word list

This was taken from [here](https://gist.github.com/cfreshman). Credit to [github.com/cfreshman](github.com/cfreshman).