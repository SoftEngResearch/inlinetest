# Simple Inline Test Demo

## TL;DR

```bash
run.sh junit
# OR
run.sh assert
```

## Demo Structure

This demo is made of the following files and directories:

* `amazon-sqs-java-extended-client-lib`: The target project to conduct the demo.
* `inlinetest-1.0.jar`: Jar for ITest -- the Java inline test framework.
* `junit-platform-console-standalone-1.12.0.jar`: JUnit standalone jar to execute JUnit inline tests with.
* `run.sh`: A `bash` script to demonstrate the process of running an inline test.
* `inline-tests`: This generated directory contains generated sources and bytecode of the inline test.
* `clean.sh`: A `bash` script to clean files generated during the demo.
* `diff.txt`: Shows the changes made to the project under demonstration. Contains lines for adding inline test dependency to `pom.xml`, adding imports, and adding the inline test itself.
* `out.txt`: Generated output of running the demo.

## Target Statement

Inline tests are designed to provide lightweight oracles for various developer-chosen inputs and outputs for complex single statements. As of now, the ITest framework majorly supports inline tests for 4 kinds of target statements:

* Bit manipulation
* String manipulation
* Regular expressions
* Java Stream

In this example, on line 887-888 of the source file `amazon-sqs-java-extended-client-lib/src/main/java/com/amazon/sqs/javamessaging/AmazonSQSExtendedClient.java`, there is a string manipulation target statement:

```java
// SQSExtendedClientConstants.S3_KEY_MARKER is "-..s3Key..-"
int secondOccurence = receiptHandle.indexOf(SQSExtendedClientConstants.S3_KEY_MARKER,
        receiptHandle.indexOf(SQSExtendedClientConstants.S3_KEY_MARKER) + 1);
```

There are more complicated examples in the wild, but this can be a good case for demonstration.

## Inline Test

An inline test can be added below this statement:

```java
itest().given(receiptHandle, "1FOc=-..s3Key..-y*-@T-..s3Key..-").checkEq(secondOccurence, 21);
```

It checks that if the variables on the right hand side of the assignment are given the values specified in the `given` clause, the value on the left hand side (`secondOccurence`) is expected to be `21`. The developer can specify multiple such inline tests below a target statement to test for different cases.

Now the enclosing method of the target statement looks like this:

```java
private String getOrigReceiptHandle(String receiptHandle) {
    int secondOccurence = receiptHandle.indexOf(SQSExtendedClientConstants.S3_KEY_MARKER,
            receiptHandle.indexOf(SQSExtendedClientConstants.S3_KEY_MARKER) + 1);
    itest().given(receiptHandle, "1FOc=-..s3Key..-y*-@T-..s3Key..-").checkEq(secondOccurence, 21);
return receiptHandle.substring(secondOccurence + SQSExtendedClientConstants.S3_KEY_MARKER.length());
}
```

In this example, the developer assigns the index of the second occurrence of `"-..s3Key..-"` in `receiptHandle` to the variable `secondOccurence`. Therefore, the inline test constructed for this example can provide different values for `receiptHandle` using the `given` clause, and check their corresponding values of `secondOccurence` with the `checkEq` clause.

## Parsing Inline Test

Parsing an inline test is defined as the process of using the ITest tool to turn a (target statement, inline test) pair, in this case these two lines:

```java
int secondOccurence = receiptHandle.indexOf(SQSExtendedClientConstants.S3_KEY_MARKER,
        receiptHandle.indexOf(SQSExtendedClientConstants.S3_KEY_MARKER) + 1);
itest().given(receiptHandle, "1FOc=-..s3Key..-y*-@T-..s3Key..-").checkEq(secondOccurence, 21);
```

to either:

1. a class with a main method and uses Java's default asserts
2. or a JUnit class that uses JUnit's asserts

This process is demonstrated in `run.sh`'s `parse_inline_test` function.

### Assertion Style

In the process of parsing an inline test, one can choose to parse inline into either a simple Java class, or a JUnit Java class.

## Compiling Inline Test

This is just using Java compiler to compile the parsed class. Details in `run.sh`'s `compile_inline_test` function.

## Executing Inline Test

Depending on the assertion style parameter, one can either directly use `java` to execute the inline test class, or use JUnit standalone jar to execute the JUnit inline test class. Details in `run.sh`'s `execute_inline_test` function.

