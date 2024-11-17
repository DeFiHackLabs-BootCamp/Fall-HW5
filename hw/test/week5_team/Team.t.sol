// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TeamBaseTest.t.sol";

contract TeamTest is TeamBaseTest {
    function test1_write_here() public checkChallenge1Solved {
        /*  write here  */
        vm.prank(mainTeam);
        team.proposeTeams(newMainTeam, newConfirmationTeam);
        vm.deal(confirmationTeam, 1 ether);
        vm.prank(confirmationTeam);
        (bool sent,) = address(team).call{value: 0.03 ether}("");
        require(sent, "Failed to send Ether");
    }

    function test2_write_here() public checkChallenge2Solved {
        /*  write here  */
        vm.deal(confirmationTeam, 1 ether);
        vm.prank(confirmationTeam);
        (bool sent,) = address(team).call{value: 0.05 ether}("");
        require(sent, "Failed to send Ether");
        vm.warp(initialTime + TIMELOCK_DURATION);
        vm.prank(mainTeam);
        vm.warp(proposeTime);
        team.proposeTeams(newMainTeam, newConfirmationTeam);
        vm.prank(newMainTeam);
        vm.warp(changeTime);
        team.changeTeams();
    }
}
