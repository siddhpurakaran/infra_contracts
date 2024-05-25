// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SequencerRandomOracle is Ownable {
    uint256 public constant SEQUENCER_TIMEOUT = 10; // Delay Timeout 
    uint256 public constant PRECOMMIT_DELAY = 10;   // Precommit delay

    // Mapping to store sequencer randomness values and their commitments
    mapping(uint256 => bytes32) public sequencerRandoms;
    mapping(uint256 => bytes32) public sequencerCommitments;
    mapping(uint256 => bool) public revealed;

    event SequencerCommitmentSet(uint256 indexed timestamp, bytes32 commitment);
    event SequencerRandomSet(uint256 indexed timestamp, bytes32 randomValue);

    error CommitmentAlreadySet();
    error RandomValueAlreadyRevealed();
    error CommitmentNotFound();
    error ValueNotAvailable();
    error DelayTimePassed();
    error CommitmentTooLate();
    error CommitmentTooEarly();

    constructor() Ownable(msg.sender) {}

    // Function to post a commitment
    function setSequencerCommitment(uint256 timestamp, bytes32 commitment) external onlyOwner {
        if (sequencerCommitments[timestamp] != bytes32(0)) {
            revert CommitmentAlreadySet();
        }
        
        if (block.timestamp > timestamp - PRECOMMIT_DELAY) {
            revert CommitmentTooLate();
        }

        sequencerCommitments[timestamp] = commitment;
        emit SequencerCommitmentSet(timestamp, commitment);
    }

    // Function to reveal a sequencer random value
    function revealSequencerRandom(uint256 timestamp, bytes32 randomValue) external onlyOwner {
        if (sequencerRandoms[timestamp] != bytes32(0)) {
            revert RandomValueAlreadyRevealed();
        }
        
        if (sequencerCommitments[timestamp] == bytes32(0)) {
            revert CommitmentNotFound();
        }

        if (block.timestamp < timestamp) {
            revert CommitmentTooEarly();
        }

        if (block.timestamp > timestamp + SEQUENCER_TIMEOUT) {
            revert DelayTimePassed();
        }

        if (keccak256(abi.encodePacked(randomValue)) != sequencerCommitments[timestamp]) {
            revert ValueNotAvailable();
        }

        sequencerRandoms[timestamp] = randomValue;
        revealed[timestamp] = true;
        emit SequencerRandomSet(timestamp, randomValue);
    }

    // Unsafe function to get sequencer random value (returns 0 if not available)
    function unsafeGetSequencerRandom(uint256 timestamp) external view returns (bytes32) {
        return sequencerRandoms[timestamp];
    }

    // Safe function to get sequencer random value (reverts if not available)
    function getSequencerRandom(uint256 timestamp) external view returns (bytes32) {
        if (sequencerRandoms[timestamp] == bytes32(0)) {
            revert ValueNotAvailable();
        }
        return sequencerRandoms[timestamp];
    }

    // Function to check if a sequencer random value will ever be available
    function willValueBeAvailable(uint256 timestamp) external view returns (bool) {
        if (sequencerRandoms[timestamp] != bytes32(0)) {
            return true;
        }

        if (block.timestamp > timestamp + SEQUENCER_TIMEOUT) {
            return false;
        }

        return sequencerCommitments[timestamp] != bytes32(0);
    }
}