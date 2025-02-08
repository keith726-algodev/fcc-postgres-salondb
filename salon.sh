#!/bin/bash

PSQL="psql --username=postgres --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ Welcome to the Salon Appointment Scheduler ~~~~~\n"

DISPLAY_SERVICES() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

while true; do
  DISPLAY_SERVICES
  echo -e "\nPlease enter the service ID you'd like:"
  read SERVICE_ID_SELECTED

  SERVICE_EXISTS=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_EXISTS ]]; then
    echo -e "\nInvalid selection. Please choose a valid service."
  else
    break
  fi
done

echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
  
  echo -e "\nYou are a new customer! Please enter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

echo -e "\nEnter the time for your appointment:"
read SERVICE_TIME

INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
