// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import "../../src/week5_team/Team.sol";

contract TeamBaseTest is Test {
    uint256 public constant TIMELOCK_DURATION = 30 days;
    Team public team;
    address mainTeam = address(0x123);
    address confirmationTeam = address(0x234);
    address newMainTeam = address(0x345);
    address newConfirmationTeam = address(0x456);
    uint256 initialTime = block.timestamp;
    uint256 proposeTime = initialTime + 31 days;
    uint256 changeTime = initialTime + 32 days;

    function setUp() public {
        team = new Team(mainTeam, confirmationTeam);
    }

    function testProposeTeams() public {
        vm.prank(mainTeam);
        team.proposeTeams(newMainTeam, newConfirmationTeam);
        assertEq(team.proposedMainTeam(), newMainTeam);
        assertEq(team.proposedConfirmationTeam(), newConfirmationTeam);
    }

    function testChangeTeam() public {
        vm.prank(mainTeam);
        team.proposeTeams(newMainTeam, newConfirmationTeam);
        vm.deal(confirmationTeam, 1 ether);
        vm.prank(confirmationTeam);
        (bool sent,) = address(team).call{value: 0.05 ether}("");
        require(sent, "Failed to send Ether");
        vm.warp(block.timestamp + 30 days);
        vm.prank(newMainTeam);
        team.changeTeams();
        assertEq(team.mainTeam(), newMainTeam);
        assertEq(team.confirmationTeam(), newConfirmationTeam);
    }

    modifier checkChallenge1Solved() {
        _;
        vm.prank(mainTeam);
        vm.expectRevert();
        team.proposeTeams(newMainTeam, newConfirmationTeam);
    }

    modifier checkChallenge2Solved() {
        _;
        assertTrue(changeTime - proposeTime < TIMELOCK_DURATION);
        assertEq(team.mainTeam(), newMainTeam);
        assertEq(team.confirmationTeam(), newConfirmationTeam);
    }
}
