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

read -p "What would you like to do? " SERVICE_ID_SELECTED

while [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'" | xargs) ]]

do

  echo "That is not a valid service. Please try again."

  echo

  display_services

  echo

  read -p "What would you like to do? " SERVICE_ID_SELECTED

done

read -p "What's your phone number? " CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)

if [[ -z $CUSTOMER_NAME ]]

then

  read -p "I don't have a record for that phone number, what's your name? " CUSTOMER_NAME

  CUSTOMER_ID=$($PSQL "SELECT COALESCE(MAX(customer_id::integer), 0) + 1 FROM customers" | xargs)

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(customer_id, phone, name) VALUES('$CUSTOMER_ID', '$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

else

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)

fi

read -p "What time would you like your service, $CUSTOMER_NAME? " SERVICE_TIME

APPOINTMENT_ID=$($PSQL "SELECT COALESCE(MAX(appointment_id::integer), 0) + 1 FROM appointments" | xargs)

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(appointment_id, customer_id, service_id, time) VALUES('$APPOINTMENT_ID', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'" | xargs)

echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
