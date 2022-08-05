---
title: "Pyminion"
summary: Dominion game engine, simulator and AI builder

# weight: 1
# aliases: ["/first"]
tags: ["Python", "Pytest"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
description: ""
showDescription: true
canonicalURL: "https://evanslack.dev/pyminion"
disableHLJS: true # to disable highlightjs
disableShare: true
disableHLJS: false
searchHidden: false
ShowReadingTime: false
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: false
ShowRssButtonInSectionTermList: false
ShowCodeCopyButtons: false
UseHugoToc: true
cover:
    image: "" # image path/url
    alt: "Placeholder" # alt text
    caption: "" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---
[pypi.org/project/pyminion](https://pypi.org/project/pyminion/)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/pyminion)

## About

Pyminion is a library for executing and analyzing games of [Dominion](https://www.riograndegames.com/games/dominion/). At its core, pyminion implements the rules and logic of Dominion and provides an API to interact with the game engine. In addition, it enables interactive games through the command line and simulation of games between bots.

## Design

Pyminion heavily relies on object oriented paradigms with inheritance and composition. 

There is a base `player` class from which both `human` and `bot` are derived. The `bot` class in particular is designed to be extendable by users to create new AI variations. All unique cards in the package are derived from the abstract `card` class, from which the `action`, `treasure` and `victory` implementations are created. State is stored in a singleton `game` instance, which is then accessed by players/bots as they take their turns. 

Currently, reactions to events such as attacks are hardcoded. In the future, it would be great to implement an callback system into the game engine which would make the handling of these sort of interrupts more extendable. 




## Example

Pyminion requires at least Python 3.8 and can easily be installed through pypi

```bash
python3 -m pip install pyminion
```

To play an interactive game through the command line against a bot, initialize a human and a bot and assign them as players. Alternatively, games can be created between multiple humans or multiple bots. 

```python
from pyminion.expansions.base import base_set 
from pyminion.game import Game
from pyminion.bots.examples import BigMoney
from pyminion.players import Human

# Initialize human and bot
human = Human()
bot = BigMoney()

# Setup the game
game = Game(players=[human, bot], expansions=[base_set])

# Play game
game.play()

```
### Creating Bots

Defining new bots is relatively straightforward. Inherit from the `Bot` class and implement play and buy strategies in the `action_priority` and `buy_priority` methods respectively.

For example, here is a simple big money + smithy bot:

```python
from pyminion.bots.bot import Bot
from pyminion.game import Game
from pyminion.expansions.base import silver, gold, province, smithy

class BigMoneySmithy(Bot):

    def __init__(
        self,
        player_id: str = "big_money_smithy",
    ):
        super().__init__(player_id=player_id)

    def action_priority(self, game: Game):
        yield smithy

    def buy_priority(self, game: Game):
        money = self.state.money
        if money >= 8:
            yield province
        if money >= 6:
            yield gold
        if money == 4:
            yield smithy
        if money >= 3:
            yield silver
```

### Running Simulations

Simulating multiple games is good metric for determining bot performance. To create a simulation, pass a pyminion game instance into the `Simulator` class and set the number of iterations to be run. 

```python
from pyminion.bots.examples import BigMoney, BigMoneySmithy
from pyminion.expansions.base import base_set, smithy
from pyminion.game import Game
from pyminion.simulator import Simulator

bm = BigMoney()
bm_smithy = BigMoneySmithy()

game = Game(players=[bm, bm_smithy], expansions=[base_set], kingdom_cards=[smithy])
sim = Simulator(game, iterations=1000)
sim.run()
```

with the following terminal output: 
```console
~$ python simulation.py
Simulation of 1000 games
big_money wins: 16.8% (168)
big_money_smithy wins: 57.5% (575)
Ties: 25.7% (257)
```
