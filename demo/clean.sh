#!/bin/bash

function clean {
    rm -rf inline-tests
    rm -rf amazon-sqs-java-extended-client-lib/target
    rm -rf amazon-sqs-java-extended-client-lib/deps.txt
    (
        cd amazon-sqs-java-extended-client-lib
        mvn clean
    )
    rm -rf out.txt
    rm -rf .DS_Store
}

clean &> /dev/null
