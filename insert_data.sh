#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# $PSQL "TRUNCATE TABLE teams restart identity CASCADE"
cat 'games.csv' | while IFS=',' read -r yr rnd wnr oppnt wgoals ogoals;
do
  if [[ $yr != 'year' ]]
  then
    WTEAM=$($PSQL "SELECT name FROM teams WHERE name = '$wnr'")
    OTEAM=$($PSQL "SELECT name FROM teams WHERE name = '$oppnt'")

    if [[ -z $OTEAM ]] # if opponent team does not exist then ->
    then
      $PSQL "INSERT INTO teams(name) VALUES('$oppnt')"
      echo $oppnt
    fi
    if [[ -z $WTEAM ]] # if winning team does not exist then ->
    then
      $PSQL "INSERT INTO teams(name) VALUES('$wnr')"
      echo $wnr
    fi
    # now the teams are added so find the opponent_id and winner_id for each team
    WID=$($PSQL "SELECT team_id FROM teams WHERE name = '$wnr'")
    OID=$($PSQL "SELECT team_id FROM teams WHERE name = '$oppnt'")
    echo -e "Winner $WID\nLoser $OID"
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($yr, '$rnd', $WID, $OID, $wgoals, $ogoals)"
  fi
done
