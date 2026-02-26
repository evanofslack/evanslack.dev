---
title: "Balatro-rs"
summary: Game engine and move generator for a simplified Balatro implementation with reinforcement learning

weight: 3
tags:
  ["Rust", "Python", "Balatro", "Reinforcement Learning", "PyO3", "Gymnasium"]
author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: true
comments: false
showDescription: false
canonicalURL: "https://evanslack.dev/balatro-rs/"
disableShare: true
disableHLJS: false
searchHidden: false
ShowReadingTime: false
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: false
ShowRssButtonInSectionTermList: false
UseHugoToc: true
cover:
  image: "/balatro-rs/balatro-rs-preview.png"
  alt: "balatro-rs"
  caption: ""
  relative: false
  hidden: false
---

[github](https://github.com/evanofslack/balatro-rs)

## About

[Balatro-rs](https://github.com/evanofslack/balatro-rs) implements a simplified version of [Balatro](https://www.playbalatro.com/) in Rust, providing both a game engine and exhaustive move generator. The library constrains the full game into a manageable state space, making it feasible to apply reinforcement learning techniques. Python bindings via [PyO3](https://pyo3.rs) enable integration with machine learning frameworks like [Gymnasium](https://gymnasium.farama.org/) for training agents.

## Features

The implementation includes a subset of Balatro's mechanics with focus on core gameplay loops:

**Implemented:**

- Poker hand identification and scoring
- Card playing, discarding, and reordering
- Blind pass/fail conditions and game progression
- Money and interest generation
- Ante progression through ante 8
- Blind types (small, big, boss)
- Stage transitions (pre-blind, blind, post-blind, shop)
- Basic joker buying, selling, and usage

**Not Implemented:**

- Tarot, planet, and spectral cards
- Boss blind modifiers
- Skip blinds and tags
- Card enhancements, foils, and seals
- Alternative decks and stakes

The goal is not full feature parity with Balatro but rather a simplified implementation suitable for reinforcement learning experiments.

## Design

The engine is built in Rust for performance and provides two distinct APIs for action generation.

The dynamic action API returns a variable-length list of all valid actions for the current game state. This approach is straightforward but less suited for fixed-size neural network inputs.

```rust
let actions: Vec<Action> = game.gen_actions().collect();
let action = actions[random_index].clone();
game.handle_action(action);
```

The action space API returns a fixed-size masked array where valid actions are marked with 1 and invalid actions with 0. This bounded representation is designed for reinforcement learning frameworks that expect consistent input dimensions.

```rust
let space = game.gen_action_space();
let space_vec = space.to_vec();
let action = space.to_action(valid_index, &game)?;
game.handle_action(action);
```

Python bindings expose both APIs through PyO3, allowing the Rust game engine to integrate with Python's machine learning ecosystem. A Gymnasium environment wrapper translates game states into observations and handles the step/reset interface expected by RL algorithms.

## Reinforcement Learning

The constrained state space enables training agents with tabular Q-learning. Game observations are reduced to a tuple of key metrics: score, target, stage, round, plays remaining, discards remaining, money, and counts of cards in various positions.

A basic Q-learning agent uses epsilon-greedy exploration to balance trying new actions with exploiting learned values. The agent maintains a dictionary mapping state-action pairs to Q-values and updates them based on temporal difference errors.

```python
agent = BalatroAgent(
    env=env,
    learning_rate=0.01,
    initial_epsilon=1.0,
    epsilon_decay=epsilon_decay,
    final_epsilon=0.1,
)

for episode in range(n_episodes):
    obs, info = env.reset()
    done = False

    while not done:
        action = agent.get_action(obs)
        next_obs, reward, terminated, truncated, info = env.step(action)
        agent.update(obs, action, reward, terminated, next_obs)
        done = terminated or truncated
        obs = next_obs

    agent.decay_epsilon()
```

Training tracks episode rewards, lengths, and temporal difference errors. The implementation is experimental and results are limited, but the infrastructure provides a foundation for exploring different RL approaches on Balatro.

## Examples

Random game simulation in Rust:

```rust
use balatro_rs::{action::Action, game::Game};
use rand::Rng;

fn main() {
    let mut game = Game::default();
    game.start();

    while !game.is_over() {
        let actions: Vec<Action> = game.gen_actions().collect();
        if actions.is_empty() {
            break;
        }

        let i = rand::thread_rng().gen_range(0..actions.len());
        let action = actions[i].clone();
        game.handle_action(action);
    }

    let result = game.result();
}
```

Random game simulation in Python:

```python
import pylatro
import random

config = pylatro.Config()
config.ante_end = 1
game = pylatro.GameEngine(config)

while not game.is_over:
    actions = game.gen_actions()
    if len(actions) > 0:
        action = random.choice(actions)
        game.handle_action(action)

print(f"Win: {game.is_win}, Score: {game.state.score}")
```

The repository includes a CLI for manual testing where players select actions interactively to step through games.

## Building

Clone and build the Rust library:

```bash
git clone https://github.com/evanofslack/balatro-rs
cd balatro-rs
cargo build --release
```

Build Python bindings with [maturin](https://github.com/PyO3/maturin):

```bash
cd pylatro
maturin develop
```

See the [pylatro](https://github.com/evanofslack/balatro-rs/tree/main/pylatro) directory for reinforcement learning experiments and Gymnasium environment setup.
