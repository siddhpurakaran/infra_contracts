// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DrandOracle is Ownable {
    uint256 public constant DRAND_TIMEOUT = 10; // Delay Timeout

    // Mapping to store drand randomness values
    mapping(uint256 => bytes32) public drandValues;

    event DrandValueSet(uint256 indexed timestamp, bytes32 value);

    error ValueAlreadySet();
    error ValueNotAvailable();
    error DelayTimePassed();

    constructor() Ownable(msg.sender) {}

    // Function to add drand value
    function setDrandValue(uint256 timestamp, bytes32 value) external onlyOwner {
        if (drandValues[timestamp] != bytes32(0)) {
            revert ValueAlreadySet();
        }
        
        if(timestamp < block.timestamp && timestamp < block.timestamp - DRAND_TIMEOUT){
            revert DelayTimePassed();
        }

        drandValues[timestamp] = value;
        emit DrandValueSet(timestamp, value);
    }

    // Unsafe function to get drand value (returns 0 if not available)
    function unsafeGetDrandValue(uint256 timestamp) external view returns (bytes32) {
        return drandValues[timestamp];
    }

    // Safe function to get drand value (reverts if not available)
    function getDrandValue(uint256 timestamp) external view returns (bytes32) {
        if (drandValues[timestamp] == bytes32(0)) {
            revert ValueNotAvailable();
        }
        return drandValues[timestamp];
    }

    // Function to check if a drand value will ever be available
    function willValueBeAvailable(uint256 timestamp) external view returns (bool) {
        if (drandValues[timestamp] != bytes32(0)) {
            return true;
        }

        if(timestamp > block.timestamp){
            return true;
        }

        uint256 timeElapsed = block.timestamp - timestamp;
        return timeElapsed <= DRAND_TIMEOUT;
    }
}
