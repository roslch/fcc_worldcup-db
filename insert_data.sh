#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # Get team_id for WINNER
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    # If not found
    if [[ -z $WINNER_ID ]]
    then
      # Insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "$WINNER has been inserted in the [teams] table."
      fi

      # Get new team_id for WINNER
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi

    # Get team_id for OPPONENT
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # If not found
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "$OPPONENT has been inserted in the [teams] table."
      fi

      # Get new team_id for OPPONENT
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi

    # Insert game data into games table.
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WIN_GOALS, $OPP_GOALS);")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Match $WINNER vs. $OPPONENT - $YEAR was inserted into [games]."
    fi
  fi
done