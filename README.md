# RockPaperScissorsContest

This smart contract implements a simple Rock-Paper-Scissors game on the Ethereum blockchain. Players can commit their moves, reveal them, and the contract automatically determines the winner based on the moves submitted by each player.

## Assumptions
1. The reward and the addresses of the players are hardcoded as they are known.
2. There is no deposit (The deposit is the reward itself):
    - If the player doesn't reveal, they lose if the other player reveals correctly.
    - If both players don't reveal, it's a draw.
3. Only one commit/reveal is allowed for each player.
4. The `secretLength` is set to 5 for simplicity. In real scenarios, it should be larger.

## High-Level Description
The code is divided into 3 phases:
1. **Commit Phase**: Each player commits their move before `playEnd`.
2. **Reveal Phase**: Each player reveals their move after `playEnd` and before `revealEnd`.
3. **Declare Winner**: The manager should declare the winner after `revealEnd`.

## Test Case
- **player1**:
    - `blindedMove`: 0x3820f3d1b70a109510ba1f1ab146d31a1bbbece20a37d0936f88def38180f334
    - `move`: 1 (Rock)
    - `secret`: ahmad

- **player2**:
    - `blindedMove`: 0x59b9e418b825788c42fa035238b333d1a9b57d38b0a31321cdc1a1423e92058c
    - `move`: 2 (Paper)
    - `secret`: gamal

**Result**: player2 is the winner

## Contract Details
- `manager`: Address of the manager who declares the winner.
- `player1` and `player2`: Addresses of the players.
- `reward`: Reward amount for the winner.
- `secretLength`: Length of the secret used for blinding the moves.
- `playEnd` and `revealEnd`: Timestamps for the end of the play and reveal phases.
- `ended`: Flag indicating if the game has ended.
- `Move`: Enum representing Rock, Paper, and Scissors.
- `player`: Struct representing player data including blinded move, actual move, and reveal status.
- `WinnerDeclared` event: Fired when the winner is declared.

## Modifiers
- `onlyManager`: Restricts functions to be called only by the manager.
- `onlyPlayers`: Restricts functions to be called only by players.
- `onlyBefore`: Ensures that a function is called only before a specific timestamp.
- `onlyAfter`: Ensures that a function is called only after a specific timestamp.

## Constructor
- Initializes the contract with play and reveal times.

## Functions
- `commitMove`: Allows players to commit their moves.
- `revealMove`: Allows players to reveal their moves.
- `declareWinner`: Allows the manager to declare the winner.
- `getWinner`: Determines the winner based on the moves submitted by players.

## License
This smart contract is licensed under the MIT License.
