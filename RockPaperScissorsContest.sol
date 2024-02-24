/*
“I acknowledge that I am aware of the academic integrity guidelines of this
course, and that I worked on this assignment independently without any
unauthorized help with coding or testing.” - <جمال عبد الحميد ناصف نويصر>
 */
/**
Assumptions:
1. The reward and the addresses of the players are hardcoded as they are known.
2. There is no deposit (The deposit is the reward itself):
    - If the player doesn't reveal, he lose if the other player reveals correctly.
    - If both didn't reveal, it's a draw.
3. Only one commit/reveal is allowed for each player.
4. The secretLength is 5 just for simplicity. In real, it should be more larger than this

High level description:
The code is divided into 3 phases (commit, reveal, and declareWinner):
    1. commit phase: each player should commit his value before playEnd.
    2. reveal phase: each player should reveal his value after playEnd and before revealEnd.
    3. declareWinner: the manager should declare the winner after revealEnd.

Testcase:
player1:
    blindedMove: 0x3820f3d1b70a109510ba1f1ab146d31a1bbbece20a37d0936f88def38180f334
    move: 1
    secret: ahmad

player2:
    blindedMove: 0x59b9e418b825788c42fa035238b333d1a9b57d38b0a31321cdc1a1423e92058c
    move: 2
    secret: gamal

Result: player2 is the winner
[
	{
		"from": "0x004754a8BBA0CaACa5F698c00757296e533460CC",
		"topic": "0x3cf1af53e79884a92609ce59db1ec9f584d88e2d14c8eaba43a21db81318301e",
		"event": "WinnerDeclared",
		"args": {
			"0": "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
			"1": "100",
			"winner": "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
			"amount": "100"
		}
	}
]
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissorsContest {
    address public manager;
    address public player1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public player2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    uint public reward = 100;
    uint secretLength = 5;
    mapping(address => player) public players;
    uint public playEnd;
    uint public revealEnd;
    bool public ended;    
    
    
    enum Move { None, Rock, Paper, Scissors }

    struct player {
        bytes32 blindedMove;
        Move move;
        bool hasRevealed;
    }

    event WinnerDeclared(address winner, uint amount);

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    modifier onlyplayers() {
        require(
            msg.sender == player1 || msg.sender == player2,
            "Only players can call this function"
        );
        _;
    }

    error TooEarly(uint time);
    error TooLate(uint time);
    error declareWinnerAlreadyCalled();
    
    modifier onlyBefore(uint time) {
        if (block.timestamp >= time) revert TooLate(time);
        _;
    }
    modifier onlyAfter(uint time) {
        if (block.timestamp <= time) revert TooEarly(time);
        _;
    }

    constructor(uint playTime, uint revealTime) payable {
        manager = msg.sender;
        require(manager != player1 && manager != player2, "Player can't be the manager");
        playEnd = block.timestamp + playTime;
        revealEnd = playEnd + revealTime;
    }

    function commitMove(bytes32 _blindedMove) external onlyplayers onlyBefore(playEnd) {
        require(players[msg.sender].blindedMove == bytes32(0), "Player already commited move!");
        players[msg.sender].blindedMove = _blindedMove;
    }

    function revealMove(Move _move, string memory _secret) external onlyplayers onlyAfter(playEnd) onlyBefore(revealEnd) {
        require(players[msg.sender].hasRevealed == false, "Player already revealed move!");   
        require(_move == Move.Rock || _move == Move.Paper || _move == Move.Scissors, "Invalid move!");
        require(bytes(_secret).length == secretLength, "Invalid secret length!");
        players[msg.sender].hasRevealed = true;
        bytes32 expectedBlindedMove = keccak256(abi.encodePacked(uint(_move), _secret));
        if (players[msg.sender].blindedMove != expectedBlindedMove) return;
        players[msg.sender].move = _move;
    }

    function declareWinner() external payable onlyManager onlyAfter(revealEnd) {
        if (ended) revert declareWinnerAlreadyCalled();
        ended = true;
        Move move1 = players[player1].move;
        Move move2 = players[player2].move;
        address winner = getWinner(move1, move2);
        if (winner == address(0)) {
            // It's a draw, distribute the reward equally
            uint halfReward = reward / 2;
            payable(player1).transfer(halfReward);
            payable(player2).transfer(halfReward);
            emit WinnerDeclared(address(0), halfReward);
        }
        else {
            // If a player wins, the reward is transferred to the winner
            payable(winner).transfer(reward);
            emit WinnerDeclared(winner, reward);
        }
    }

    function getWinner(Move move1, Move move2) internal view returns (address) {
        if (move1 == Move.None && move2 == Move.None) {
            // Both players have not submitted moves, it's a draw
            return address(0);
        }
        else if (move1 == Move.None) {
            // if player 1 has not submitted a move, player 2 wins
            return player2;
        }
        else if (move2 == Move.None) {
            // if player 2 has not submitted a move, player 1 wins
            return player1;
        }
        else if (move1 == move2) {
            // It's a draw
            return address(0);
        }
        else if (
            (move1 == Move.Rock && move2 == Move.Scissors) ||
            (move1 == Move.Paper && move2 == Move.Rock) ||
            (move1 == Move.Scissors && move2 == Move.Paper)
        ) {
            // player 1 wins
            return player1;
        }
        else {
            // player 2 wins
            return player2;
        }
    }
}
