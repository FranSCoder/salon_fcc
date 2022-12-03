#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Hair Salon ~~~~~\n";

MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # show the service list

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME" ;
  done

  echo -e "\nPlease, select a service:"

  read SERVICE_ID_SELECTED;

  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # if pick the wrong service

  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    # show the service list again
    MENU "Sorry, that was not a valid Service ID."
  else
    # else, enter phone
    echo -e "\nPlease, enter your phone number:"
    read CUSTOMER_PHONE

    # if phone does not exist, get name and insert data in customers
    CUSTOMER_PHONE_COINCIDENCE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_PHONE_COINCIDENCE ]]
    then
      echo -e "\nPlease, enter your name:"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get customer id and name
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # get appointment time
    echo -e "\nPlease, choose a time (FORMAT HH:MM) for your appointment:"
    read SERVICE_TIME

    # insert appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    
  fi
}

MENU;

