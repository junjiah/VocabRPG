# VocabRPG
A mobile game for memorizing English words.

Here documents the underlying model for vocabulary and memorization.

In essence, the model has following functionalities:

- Store the player's vocabulary records in Core Data
    1. the *word*
    2. player's *proficiency*, measured in the number of times the player has reviewed this word
    3. *priority* of this word to display during the game
- Provide a reasonable mixture of words for players during the combat scene
    1. some of those words should be ones the player needs to review based on their priorities
    2. some should be new words
- Record the player's result into the database
- Update the words' priorities based when the player played the game

##  1. Model

The model has only one table, with three columns: *word*, *priority*, *priority*. The first is of string type and the other two should be integers.

**Proficiency** is simply the times of reviews with regard to this word. If the player  gives a right match, *proficiency* will increase by 1, otherwise it should decrease by 1 but should never be lower than 1. This attribute determines the character's strengths. 
