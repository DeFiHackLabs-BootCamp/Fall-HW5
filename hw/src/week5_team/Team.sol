// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// A smart contract which provides two Team addresses (a main and confirmation Team) which can be changed using the following mechanism:
// 1. Main Team can propose a new main Team and confirmation Team.
// 2. Confirmation Team confirms or rejects.
// 3. There is a timelock of 30 days before the proposed mainTeam can confirm the change.

contract Team {
    event TeamProposal(address proposedMainTeam, address proposedConfirmationTeam);
    event TeamChange(address mainTeam, address confirmationTeam);

    uint256 public constant TIMELOCK_DURATION = 30 days;

    // The active main and confirmation Teams
    address public mainTeam;
    address public confirmationTeam;

    // Proposed Teams
    address public proposedMainTeam;
    address public proposedConfirmationTeam;

    // Active timelock
    uint256 public activeTimelock;

    constructor(address _mainTeam, address _confirmationTeam) {
        mainTeam = _mainTeam;
        confirmationTeam = _confirmationTeam;

        // Write a value so subsequent writes take less gas
        activeTimelock = type(uint256).max;
    }

    // Make a request to change the main and confirmation Teams.
    function proposeTeams(address _proposedMainTeam, address _proposedConfirmationTeam) external {
        require(msg.sender == mainTeam, "Only the current mainTeam can propose changes");
        require(_proposedMainTeam != address(0), "_proposedMainTeam cannot be the zero address");
        require(_proposedConfirmationTeam != address(0), "_proposedConfirmationTeam cannot be the zero address");

        // Make sure we're not overwriting a previous proposal (as only the confirmationTeam can reject proposals)
        require(proposedMainTeam == address(0), "Cannot overwrite non-zero proposed mainTeam.");

        proposedMainTeam = _proposedMainTeam;
        proposedConfirmationTeam = _proposedConfirmationTeam;

        emit TeamProposal(proposedMainTeam, proposedConfirmationTeam);
    }

    // The confirmation Team confirms or rejects Team proposals by sending a specific amount of ETH to this contract
    receive() external payable {
        require(msg.sender == confirmationTeam, "Invalid sender");

        // Confirm if 0.05 or more ether is sent and otherwise reject.
        // Done this way in case custodial Teams are used as the confirmationTeam - which sometimes won't allow for smart contract calls.
        if (msg.value >= 0.05 ether) {
            activeTimelock = block.timestamp + TIMELOCK_DURATION;
        } // establish the timelock
        else {
            activeTimelock = type(uint256).max;
        } // effectively never
    }

    // Confirm the Team proposals - assuming that the active timelock has already expired.
    function changeTeams() external {
        // proposedMainTeam calls the function - to make sure it is a valid address.
        require(msg.sender == proposedMainTeam, "Invalid sender");
        require(block.timestamp >= activeTimelock, "Timelock not yet completed");

        // Set the Teams
        mainTeam = proposedMainTeam;
        confirmationTeam = proposedConfirmationTeam;

        emit TeamChange(mainTeam, confirmationTeam);

        // Reset
        activeTimelock = type(uint256).max;
        proposedMainTeam = address(0);
        proposedConfirmationTeam = address(0);
    }
}
