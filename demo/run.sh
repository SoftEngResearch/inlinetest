#!/bin/bash

ASSERTION_STYLE=$1

PROJECT_NAME="amazon-sqs-java-extended-client-lib"
ITEST_JAR="inlinetest-1.0.jar"
JUNIT_JAR="junit-platform-console-standalone-1.12.0.jar"

function install_inlinetest {
    echo "===== Installing inlinetest ====="
    mvn install:install-file -Dfile=${ITEST_JAR} -DgroupId=org.inlinetest -DartifactId=inlinetest -Dversion=1.0 -Dpackaging=jar --no-transfer-progress
}

function get_dependencies_and_compile {
    echo "===== Collecting dependencies and compiling ====="
    (
        cd "${PROJECT_NAME}"
        mvn dependency:build-classpath -Dmdep.outputFile=deps.txt --no-transfer-progress
        mvn clean compile --no-transfer-progress
    )
}

function parse_inline_test {
    echo "===== Parsing inline test ====="
    local output_dir="inline-tests/src"
    mkdir -p "${output_dir}"
    java -cp "${ITEST_JAR}" org.inlinetest.InlineTestRunnerSourceCode --input_file=${PROJECT_NAME}/src/main/java/com/amazon/sqs/javamessaging/AmazonSQSExtendedClient.java --assertion_style="${ASSERTION_STYLE}" --output_dir="${output_dir}" --multiple_test_classes=true --dep_file_path=${PROJECT_NAME}/deps.txt --app_src_path=${PROJECT_NAME}/src/main/java
}

function compile_inline_test {
    echo "===== Compiling inline test ====="
    local input_dir="inline-tests/src"
    local output_dir="inline-tests/bin"
    mkdir -p "${output_dir}"
    javac -cp "$(cat ${PROJECT_NAME}/deps.txt)":${ITEST_JAR}:${input_dir}:${PROJECT_NAME}/target/classes -d "${output_dir}" ${input_dir}/*.java
}

function execute_inline_test {
    echo "===== Executing inline test ====="
    if [ "${ASSERTION_STYLE}" == "junit" ]; then
        java -jar "${JUNIT_JAR}" -cp "$(cat ${PROJECT_NAME}/deps.txt | sed 's|target/test-classes||g')":inline-tests/bin --select-package com.amazon.sqs.javamessaging
    elif [ "${ASSERTION_STYLE}" == "assert" ]; then
        java -cp "${PROJECT_NAME}/target/classes:inline-tests/bin" com.amazon.sqs.javamessaging.AmazonSQSExtendedClient_0Test
    else
        echo "Invalid assertion style: ${ASSERTION_STYLE}"
        exit 1
    fi
}

function main {
    install_inlinetest
    get_dependencies_and_compile
    parse_inline_test
    compile_inline_test
    execute_inline_test
}

main &> out.txt
