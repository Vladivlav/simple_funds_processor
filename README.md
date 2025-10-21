This is a solution for a test assignment.

How to run a program:
  ruby input_processor.rb

Artefacts:
1. Program works with NDJSON placed in the root directory with input.txt filename.
2. Program generates result as an output.txt file in the root directory

Assumptions:
1. Program works only with records sorted by time in ASC
2. One line params from input:
    a. Each line contains a valid JSON with attributes customer_id, id, funds_amount, time
    b. time has a string contain dattime by +0 timezone
    c. funds_amount always present in USD with decimals and can start with symbols '$' or 'USD'
    d. customer_id and id are integer numbers that can be presentes as a strings
    f. Each records contain time value greater that time of last proceeeded record
3. On daily and monthly limits we assume that each day and month starts in +0 UTC