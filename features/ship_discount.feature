Feature: ShipDiscount
  Shipping discount calculator is a CLI application

  Scenario: Shows help if invoked with short option
    When I run `ship_discount -h`
    Then the output should contain "Usage:"
    And the exit status should be 1

  Scenario: Shows help if invoked with long option
    When I run `ship_discount --help`
    Then the output should contain "Usage:"
    And the exit status should be 1

  Scenario: Shows help if invoked with too many positional args
    When I run `ship_discount file1 file2`
    Then the output should contain "Usage:"
    And the exit status should be 1

  Scenario: Fails without input file
    Given an empty directory named "empty_dir"
    When I cd to "empty_dir"
    And I run `ship_discount`
    Then the output should contain "ERROR: Input file input.txt can not be found"
    And the exit status should not be 0

  Scenario: Fails with too many parameters
    When I run `ship_discount one two`
    Then the output should contain "ERROR: Wrong number of arguments specified"
    And the exit status should not be 0

  Scenario: Succeeds with empty input.txt if invoked without parameters
    Given an empty directory named "input_txt"
    And I cd to "input_txt"
    And an empty file named "input.txt"
    When I run `ship_discount`
    Then the output should contain exactly ""
    And the exit status should be 0

  Scenario: Succeeds with example input.txt if invoked without parameters
    Given an empty directory named "input_txt"
    And I cd to "input_txt"
    And the file named "input.txt" with:
    """
    2015-02-01 S MR
    2015-02-02 S MR
    2015-02-03 L LP
    2015-02-05 S LP
    2015-02-06 S MR
    2015-02-06 L LP
    2015-02-07 L MR
    2015-02-08 M MR
    2015-02-09 L LP
    2015-02-10 L LP
    2015-02-10 S MR
    2015-02-10 S MR
    2015-02-11 L LP
    2015-02-12 M MR
    2015-02-13 M LP
    2015-02-15 S MR
    2015-02-17 L LP
    2015-02-17 S MR
    2015-02-24 L LP
    2015-02-29 CUSPS
    2015-03-01 S MR
    """
    When I run `ship_discount`
    Then the output should contain exactly:
    """
    2015-02-01 S MR 1.50 0.50
    2015-02-02 S MR 1.50 0.50
    2015-02-03 L LP 6.90 -
    2015-02-05 S LP 1.50 -
    2015-02-06 S MR 1.50 0.50
    2015-02-06 L LP 6.90 -
    2015-02-07 L MR 4.00 -
    2015-02-08 M MR 3.00 -
    2015-02-09 L LP 0.00 6.90
    2015-02-10 L LP 6.90 -
    2015-02-10 S MR 1.50 0.50
    2015-02-10 S MR 1.50 0.50
    2015-02-11 L LP 6.90 -
    2015-02-12 M MR 3.00 -
    2015-02-13 M LP 4.90 -
    2015-02-15 S MR 1.50 0.50
    2015-02-17 L LP 6.90 -
    2015-02-17 S MR 1.90 0.10
    2015-02-24 L LP 6.90 -
    2015-02-29 CUSPS Ignored
    2015-03-01 S MR 1.50 0.50
    """
    And the exit status should be 0

  Scenario: Succeeds with example file.txt if invoked without file name
    Given an empty directory named "file_txt"
    And I cd to "file_txt"
    And the file named "file.txt" with:
    """
    2015-02-01 S MR
    2015-02-02 S MR
    2015-02-03 L LP
    2015-02-05 S LP
    2015-02-04 S MR
    """
    When I run `ship_discount file.txt`
    Then the output should contain exactly:
    """
    2015-02-01 S MR 1.50 0.50
    2015-02-02 S MR 1.50 0.50
    2015-02-03 L LP 6.90 -
    2015-02-05 S LP 1.50 -
    2015-02-04 S MR Ignored
    """
    And the exit status should be 0
