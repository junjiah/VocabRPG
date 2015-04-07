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

I didn't do a very thorough calculation on this formula, but the temporary strategy is to divide the memorized vocabulary into 4 parts based on their values of proficiency: (1, 5], (6, 10], (11, 15] and (16, 20]. Use $G_i$ to denote these groups respectively where $i \in \{1,2,3,4\}$, and *S* to denote the strength:

$$ S = 1\times G_2 + 5\times G_3 + 100 \times G_4 + 10 $$

Again, its upper bound is 9999.

**UPDATE**: Inspired by my friend [yuetaoxu](https://github.com/yuetaoxu) I have a better idea. First model the proficiency as a fraction (let's call it $P$).

$$ P_n = 1 - 0.95\^n $$

Where $n$ denotes the proficiency ranging from 1 to 20. Then do average, and we could get the average $P_{avg}$.

We also know $P_{20} \approx 0.64$, and the strength could be represented as: 

$$ S = 100 \times \frac{P\_{avg}}{P\_{MAX}} $$

Also for reference, here provides a table indicating the relationship between *proficiency* and *learning time* (in days, where *Int* means interval and *Acc* means accumulated time).

| Prof | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| ------ | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | 
| Int   | 0 | 1 | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 |
|  Acc | - | 1 | 2 | 3 | 5 | 7 | 10 | 13 | 17 | 21 |

| Prof | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
| ------ | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | 
| Int | 5 | 5 | 6 | 6 | 7 | 7 | 8 | 8 | 9 | 9 |
| Acc | 26 | 31 | 37 | 43 | 50 | 57 | 65 | 73 | 82 | 91 |

In this way, a new word can only contribute value of 0.05 while a month later it became 0.46 (with proficiency 12), and the word of maximum proficiency could contribute 0.64, which seems fair.

## 5. Enemy Development

Currently the *evolution* of enemy is purely based on heuristics, and my next step is to develop a numerical test system to emulate the battle between the hero and the monster such that given a desired numeric property (say, *word matching correctness*) the system could generate the appropriate properties - HP and strength - of the enemy.

As for now, the enemy's evolution is linear

$$ \mbox{Enemy HP} = s_{HP} + \mbox{level} \times (3.2 \times \mbox{Hero Strength}) $$

Where $s_{HP}$ denotes the starting HP for the enemy (15 or 20, for example).

$$ \mbox{Enemy Strength} = s_{str} + \mbox{level} \times \frac{\mbox{Hero HP}}{5} $$

Similarly $s_{str}$ denotes the starting strength of the enemy.

******

Hopefully I would not forget those stuff.
