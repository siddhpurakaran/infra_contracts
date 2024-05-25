// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";

import {DrandOracle} from "../src/DrandOracle.sol";
import {SequencerRandomOracle} from "../src/SequencerRandomOracle.sol";
import {RandomnessOracle} from "../src/RandomnessOracle.sol";

contract DeployOracles is Script {
    uint256 public deployerKey = vm.envUint("DEPLOYER_KEY");

    function run() external {
        console.log("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");

        vm.startBroadcast(deployerKey);
        DrandOracle drandOracle = new DrandOracle();
        console.log("DrandOracle Deployed : %s", address(drandOracle));
        console.log("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");

        SequencerRandomOracle sequencerRandomOracle = new SequencerRandomOracle();
        console.log("SequencerRandomOracle Deployed : %s", address(sequencerRandomOracle));
        console.log("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");

        RandomnessOracle randomnessOracle = new RandomnessOracle(drandOracle, sequencerRandomOracle);
        console.log("RandomnessOracle Deployed : %s", address(randomnessOracle));
        console.log("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
        vm.stopBroadcast();
    }
}
