Feature: Javascript Object Creation
  As a consumer of the gatherable gem
  I should be able to generate javascript objects
  And those objects should correctly communicate with the gatherble API

  Background:
    Given I am collecting a one dimensional data point called 'price'

  @javascript
  Scenario Outline: Communicating with the gatherable API via ajax calls
    Given the gatherable API <requires_global_id>
    When I <crud_verb> an object
    Then the object will be <crud_verb>ed

    Examples:
      | requires_global_id        | crud_verb |
      | requires global id        | show      |
      | requires global id        | index     |
      | requires global id        | create    |
      | requires global id        | update    |
      | requires global id        | destroy   |
      | doesn't require global id | show      |
      | doesn't require global id | index     |
      | doesn't require global id | create    |
      | doesn't require global id | update    |
      | doesn't require global id | destroy   |
