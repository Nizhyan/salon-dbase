#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -t --no-align -c"

echo "Welcome to our services!"
echo

display_services() {
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS='|' read -r id name
  do
    id=$(echo $id | xargs)
    name=$(echo $name | xargs)
    echo "${id}) ${name}"
  done
}

display_services

echo
echo "What would you like to do?"
read SERVICE_ID_SELECTED

while [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]
do
  echo "That is not a valid service. Please try again."
  echo
  display_services
  echo
  echo "What would you like to do?"
  read SERVICE_ID_SELECTED
done

echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | head -1 | xargs)

if [[ -z $CUSTOMER_NAME ]]
then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_ID=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id" | head -1 | xargs)
else
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | head -1 | xargs)
fi

echo "What time would you like your service, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | head -1 | xargs)

echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
