#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
  echo "Enter your username:"
  read USERNAME

  USER_ID=$(echo $($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'") | sed 's/ //g')

  #check if user has already played 
  if [[ -z $USER_ID ]]
   then
    INSERT_INTO_USERS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$(echo $($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'") | sed 's/ //g')
    echo "Welcome, $USERNAME! It looks like this is your first time here." 
   else 
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id='$USER_ID'")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id='$USER_ID'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi 

  RANDOM_NUMBER=$(($RANDOM % 1000 + 1))

  echo "Guess the secret number between 1 and 1000:"
  GUESS_COUNT=0
  read GUESSED_NUMBER

  until [[ $GUESSED_NUMBER == $RANDOM_NUMBER ]]
    do
    if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
      then
      echo "That is not an integer, guess again:"
      read GUESSED_NUMBER
      ((GUESS_COUNT++))
      else 
      if [[ $GUESSED_NUMBER > $RANDOM_NUMBER ]] 
        then
          echo "It's lower than that, guess again:"
          read GUESSED_NUMBER
          ((GUESS_COUNT++))
        elif [[ $GUESSED_NUMBER < $RANDOM_NUMBER ]]
          then
          echo "It's higher than that, guess again:"
          read GUESSED_NUMBER
          ((GUESS_COUNT++))
      fi
    fi
  done

((GUESS_COUNT++))


INSERT_NUMBER_OF_GUESSES=$($PSQL "INSERT INTO games(user_id,number_of_guesses) VALUES($USER_ID, $GUESS_COUNT)")

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"