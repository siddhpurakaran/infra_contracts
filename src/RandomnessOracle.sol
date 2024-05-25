// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DrandOracle.sol";
import "./SequencerRandomOracle.sol";

contract RandomnessOracle {
    DrandOracle public drandOracle;
    SequencerRandomOracle public sequencerRandomOracle;

    uint256 public constant DELAY = 9; // Configurable delay in seconds

    // Custom error for value not available
    error ValueNotAvailable();

    constructor(DrandOracle _drandOracle, SequencerRandomOracle _sequencerRandomOracle) {
        drandOracle = _drandOracle;
        sequencerRandomOracle = _sequencerRandomOracle;
    }

    // Computes the randomness(timestamp) value on the fly
    function computeRandomness(uint256 timestamp) public view returns (bytes32) {
        if (timestamp % 2 != 0) {
            return bytes32(0); // No block at odd timestamps
        }

        bytes32 drandValue = drandOracle.unsafeGetDrandValue(timestamp - DELAY);
        bytes32 sequencerValue = sequencerRandomOracle.unsafeGetSequencerRandom(timestamp);

        if (drandValue == bytes32(0) || sequencerValue == bytes32(0)) {
            return bytes32(0);
        }

        return keccak256(abi.encodePacked(drandValue, sequencerValue));
    }

    // Unsafe function to get the randomness value (returns 0 if not available)
    function unsafeGetRandomness(uint256 timestamp) external view returns (bytes32) {
        return computeRandomness(timestamp);
    }

    // Safe function to get the randomness value (reverts if not available)
    function getRandomness(uint256 timestamp) external view returns (bytes32) {
        bytes32 randomness = computeRandomness(timestamp);
        if (randomness == bytes32(0)) {
            revert ValueNotAvailable();
        }
        return randomness;
    }

    // Function to check if a randomness value will ever be available
    function willRandomnessBeAvailable(uint256 timestamp) external view returns (bool) {
        if (timestamp % 2 != 0) {
            return false; // No block at odd timestamps
        }

        bool willDrandBeAvailable = drandOracle.willValueBeAvailable(timestamp - DELAY);
        bool willSequencerBeAvailable = sequencerRandomOracle.willValueBeAvailable(timestamp);

        return willDrandBeAvailable && willSequencerBeAvailable;
    }
}
