#!/bin/bash

echo -e "\nEnter your username:"
read NAME

RND=$(( ( RANDOM % 1000 )  + 1 ))
echo $RND
#RND=5
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

if [[ -z $($PSQL "SELECT user_id FROM users WHERE name = '$NAME'") ]]
then
  # no user in DB
  echo -e "Welcome, $NAME! It looks like this is your first time here.\n"
  INSERT=$($PSQL "INSERT INTO users(name) VALUES('$NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")
else
  # user already in DB
  UI1=$($PSQL "SELECT user_id, best_game FROM users WHERE name='$NAME'")
  UI1=$(echo $UI1 | sed 's/|/ /g')
  UI1=($UI1)
  USER_ID=${UI1[0]}
  BEST_GAME=${UI1[1]}
  GAMES_TOTAL=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  echo -e "\nWelcome back, $NAME! You have played $GAMES_TOTAL games, and your best game took $BEST_GAME guesses."
fi

INS_GAME=$($PSQL "INSERT INTO games(user_id, guessed_number) VALUES($USER_ID, $RND)")

echo "Guess the secret number between 1 and 1000:"

C=0
while true
do
  read NUMBER

  if [[ ! $NUMBER =~ ^[0-9]+$ ]] 
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $NUMBER -eq $RND ]]
    then
      #echo "TRUE" 
      C=$((C+1))
      BG=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
      if [[ $BG -eq 0 ]] || [[ $C -lt $BG ]]
      then
        INS=$($PSQL "UPDATE users SET best_game=$C WHERE user_id=$USER_ID")
      fi
      break
    elif [[ $NUMBER -lt $RND ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      C=$((C+1))
    else
      echo -e "\nIt's lower than that, guess again:"
      C=$((C+1))
    fi
  fi
done

echo -e "You guessed it in $C tries. The secret number was $RND. Nice job!"
