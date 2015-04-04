<head>
    <script type="text/javascript"
            src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
    </script>
</head>

# VocabRPG
VocabRPG is A mobile game for memorizing English words.

Here documents the underlying model for vocabulary and memorization.

In essence, the model has following functionalities:

- Store the player's vocabulary records in Core Data in terms of
    1. the string of the *word*
    2. player's *proficiency*, measured in the number of player reviews
    3. *priority* of the word to be displayed during the game
- Provide a reasonable mixture of words for players during the combat scene
    1. some of those words are to be reviewed
    2. some should be randomly chosen words (not necessarily to be new)
- Update the words' priorities based on the passage of time

##  1. Model

The model has only one table, with three columns: *word*, *proficiency*, *priority*. The first is of string type and the other two should be integers.

**Proficiency** is simply the times of reviews with regard to a particular word, ranging from 1 to 20. If the player gives a right match in the combat, *proficiency* will increase by 1, otherwise it should decrease by 1. This attribute determines the character's strengths. 

**Priority** dictates which word to be presented to the player. The rule will be explained in following sections.

## 2. Word Selection

Current strategy is to select 2/3 of displayed words to be ones which needs reviewing, while the other 1/3 would be new words. 

The to-be-reviewed words are selected from core data according to their priorities and proficiencies such that words with highest priority and lowest proficiency would be preferred.

## 3. Priority Updates

Suppose the first day for the player to play this game is called *Day 0*. The game maintains a variable called `playedDays` to record the difference between current data and *Day 0*.

Now if the player encounters a new word and has a right match, the game will put the word into the model and give it a priority of `playedDays + 1` indicating the player should review this word tomorrow. 

For already reviewed words the priority should be `playedDays + calculateNextReviewTimeFor(proficiency)` which `calculateNextReviewTimeFor` is a self-explanatory function. On the other hand if the player provides a wrong match, the priority should again be `playedDays + 1`, regardless of its proficiency.

## 4. Relation with Character Development

### Health Point

Currently the hero's HP is solely based on the number of memorized vocabulary size:

$$ HP = 0.4 \times \left(\frac{V}{100}\right)^2 + 20$$ 

*V* denotes the size of memorized vocabulary size.

To give a sense of this function, here provides some example values:

$$ HP(100) \approx 20, ~ HP(1000) = 60, ~ HP(10000) = 4020 $$

The upper bound of *HP* is 9999.

### Strength

I didn't do a very thorough calculation on this formula, but the temporary strategy is to divide the memorized vocabulary into 4 parts based on their values of proficiency: (1, 5], (6, 10], (11, 15] and (16, 20]. Use \\(G_i, i \in \\{1,2,3,4\\}\\) to denote these groups respectively, and *S* to denote the strength:


$$ S = 1\times G\_2 + 5\times G\_3 + 100 \times G\_4 + 10 $$

Again, its upper bound is 9999.

******

Hopefully I would not forget this.
