This is a solution for a test assignment.
  
To execute the program, run the following command in your terminal from the root directory:
```ruby
ruby input_processor.rb
```
  
## Program Artefacts:

1. Program works with NDJSON placed in the root directory with input.txt filename.
2. Program generates result as an output.txt file in the root directory
  
## Assumptions:

1. Program works only with records sorted by time in ASC
2. One line params from input:
    * Each line contains a valid JSON with attributes customer_id, id, funds_amount, time
    * time has a string contain dattime by +0 timezone
    * funds_amount always present in USD with decimals and can start with symbols '$' or 'USD'
    * customer_id and id are integer numbers that can be presentes as a strings
    * Each records contain time value greater that time of last proceeeded record
3. On daily and monthly limits we assume that each day and month starts in +0 UTC
