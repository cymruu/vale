Feature: Config
  Background:
    Given a file named "test.md" with:
    """
    This is a very important sentence. There is a sentence here too. javascript

    """
    And a file named "test.py" with:
    """
    # There is always something to say. Very good! (e.g., this is good)

    """

  Scenario: MinAlertLevel = warning
    Given a file named ".vale" with:
    """
    MinAlertLevel = warning

    [*]
    BasedOnStyles = vale
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    """
    And the exit status should be 0

  Scenario: MinAlertLevel = error
    Given a file named ".vale" with:
    """
    MinAlertLevel = error

    [*]
    BasedOnStyles = vale
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    """
    And the exit status should be 0

  Scenario: External config
    When I lint with config "../../fixtures/styles/demo"
    Then the output should contain exactly:
      """
      test.md:15:60:demo.Spellcheck:Did you really mean 'codeblock'?
      test.md:34:29:demo.Filters:Did you really mean 'TODO'?
      test.md:36:3:demo.Filters:Did you really mean 'TODO'?
      test.md:36:16:demo.Filters:Did you really mean 'FIXME'?
      test.md:40:21:demo.Filters:Did you really mean 'FIXME'?
      test.md:42:9:demo.Spellcheck:Did you really mean 'Monokai'?
      test.md:44:5:demo.Filters:Did you really mean 'TODO'?
      test.md:46:3:demo.Filters:Did you really mean 'TODO'?
      """
    And the exit status should be 0

  Scenario: Ignore BasedOnStyle for formats it doesn't match
    Given a file named ".vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.py]
    BasedOnStyles = vale
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    """
    And the exit status should be 0

  Scenario: Specify BasedOnStyle on a per-syntax basis
    Given a file named ".vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.md]
    BasedOnStyles = vale

    [*.py]
    BasedOnStyles = write-good
    write-good.E-Prime = NO
    """
    When I run vale "."
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Disable/enable checks on a per-syntax basis
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.md]
    BasedOnStyles = vale

    [*.py]
    BasedOnStyles = write-good
    write-good.E-Prime = NO
    write-good.Weasel = NO
    """
    When I run vale "."
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    """
    And the exit status should be 1

  Scenario: Overwrite BasedOnStyle on a per-syntax basis
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = vale

    [*.py]
    BasedOnStyles = write-good
    write-good.E-Prime = NO
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Overwrite disabled rules on a per-syntax basis
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = write-good
    write-good.Weasel = NO

    [*.py]
    write-good.Weasel = YES
    """
    When I run vale "test.py test.md"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Load two base styles
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = Joblint, write-good
    write-good.E-Prime = NO
    """
    When I run vale "test.py test.md"
    Then the output should contain exactly:
    """
    test.md:1:11:write-good.Weasel:'very' is a weasel word!
    test.md:1:66:Joblint.TechTerms:Use 'JavaScript' instead of 'javascript'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Load individual rules
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = vale
    write-good.ThereIs = YES
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:vale.Editorializing:Consider removing 'Very'
    """
    And the exit status should be 1

  Scenario: Load section with glob as name
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.{md,py}]
    BasedOnStyles = vale
    write-good.ThereIs = YES
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:vale.Editorializing:Consider removing 'Very'
    """
    And the exit status should be 1

  Scenario: Test a glob
    When I test glob "*.{py,cc}"
    Then the output should contain exactly:
    """
    test.cc:1:4:vale.Annotations:'XXX' left in text
    test.cc:9:6:vale.Annotations:'NOTE' left in text
    test.cc:13:6:vale.Annotations:'XXX' left in text
    test.cc:17:5:vale.Annotations:'FIXME' left in text
    test.cc:20:5:vale.Annotations:'XXX' left in text
    test.cc:23:37:vale.Annotations:'XXX' left in text
    test.py:1:3:vale.Annotations:'FIXME' left in text
    test.py:5:5:vale.Annotations:'FIXME' left in text
    test.py:11:3:vale.Annotations:'XXX' left in text
    test.py:13:16:vale.Annotations:'XXX' left in text
    test.py:14:14:vale.Annotations:'NOTE' left in text
    test.py:17:1:vale.Annotations:'NOTE' left in text
    test.py:23:1:vale.Annotations:'XXX' left in text
    test.py:28:5:vale.Annotations:'NOTE' left in text
    test.py:35:8:vale.Annotations:'NOTE' left in text
    test.py:37:5:vale.Annotations:'TODO' left in text
    """
    And the exit status should be 0


  Scenario: Test a negated glob
    When I test glob "!*.md"
    Then the output should not contain "md"
    And the exit status should be 0

  Scenario: Test another negated glob
    When I test glob "!*.{md,py}"
    Then the output should not contain "md"
    And the output should not contain "py"
    And the exit status should be 0

  Scenario: Change a built-in rule's level
    Given a file named ".vale" with:
    """
    MinAlertLevel = error

    [*]
    vale.Editorializing = error
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    """
    And the exit status should be 1

  Scenario: Change an external rule's level
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = error

    [*.{md,py}]
    write-good.Weasel = error
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1
