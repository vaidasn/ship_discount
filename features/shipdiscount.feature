Feature: Shipdiscount
  Shipping discount calculator is a CLI application

  Scenario: Shows help if invoked with short option
    When I run `shipdiscount -h`
    Then the output should contain "Usage:"
    And the exit status should be 1

  Scenario: Shows help if invoked with long option
    When I run `shipdiscount --help`
    Then the output should contain "Usage:"
    And the exit status should be 1

  Scenario: Shows help if invoked with too many positional args
    When I run `shipdiscount file1 file2`
    Then the output should contain "Usage:"
    And the exit status should be 1

  Scenario: Succeeds if invoked without parameters
    Given an empty directory named "input_txt"
    And an empty file named "input.txt"
    When I run `shipdiscount`
    Then the output should contain "Succeeded"
    And the exit status should be 0

  Scenario: Fails without input file
    Given an empty directory named "empty_dir"
    When I cd to "empty_dir"
    And I run `shipdiscount`
    Then the output should contain "Failed"
    And the exit status should not be 0
