#!/bin/bash
#psql --username=postgres --dbname=tiziano
PSQL="psql --username=postgres --dbname=tiziano -t --no-align -c"

PROGRAMA(){
    reset=$($PSQL "TRUNCATE jobs, type_jobs")
    echo $reset

    cat clientes_test1.csv | while IFS="," read NAME YEAR MONTH JOB CAR AMOUNT COST
    do
        #stataments
        if [[ job != $JOB ]]
        then  
            JOB_ID=$($PSQL "SELECT job_id FROM type_jobs WHERE name='$JOB'")
            
            if [[ -z $JOB_ID ]]
            then
                INSERT_JOB=$($PSQL "INSERT INTO type_jobs(name) VALUES('$JOB')")

                if [[ $INSERT_JOB == "INSERT 0 1" ]]
                then
                    echo inserted into type of jobs, $JOB
                fi

                
                JOB_ID=$($PSQL "SELECT job_id FROM type_jobs WHERE name='$JOB'")
            fi

            

            INSERT_DATA_JOBS=$($PSQL "INSERT INTO jobs(client, year, car, job, month, amount, cost) VALUES('$NAME', $YEAR, '$CAR', $JOB_ID, $MONTH, $AMOUNT, $COST)")
        

        fi

    done
}

S_MONTH(){

    echo -e "\n\nDATA PER MONTH"

    echo -e "\nSelect month to see data:"
    read MONTH_SELECTED

    if [[ $MONTH_SELECTED =~ ^[1-9]+$ ]]
    then
        GET_TOTAL_AMOUNT=$($PSQL "SELECT SUM(amount) FROM jobs WHERE month=$MONTH_SELECTED")
        echo -e "\nTotal amount earned without cost:"
        echo $GET_TOTAL_AMOUNT

        GET_TOTAL_COST=$($PSQL "SELECT SUM(cost) FROM jobs WHERE month=7")
        echo -e "\nTotal cost:"
        echo $GET_TOTAL_COST

        echo -e "\nTotal amount earned WITH COST:"
        GET_REST=$($PSQL "SELECT SUM(amount) - SUM(cost) FROM jobs")
        echo $GET_REST
    else    
        echo -e "\nYou need to select a number, the program is going to reset.\n"
        PROGRAMA
        S_MONTH

    fi
}

PROGRAMA
S_MONTH