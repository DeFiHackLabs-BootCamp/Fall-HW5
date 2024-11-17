# HW4 Solution
## Task: Team

### Description
Modify the contract from the audit competition, freely use cheat codes.
Write your solution in `Team.t.sol`, without modifying other code.  
Try to pass the tests in `TeamBaseTest.t.sol`.

### Solution: 1 
The changing mechanism of Team requires a proposal and confirmation. 
The value activeTimelock is updated each time the receive function is triggered.
However, when a new proposeTeams is rejected (for example, wrong address input by mistake), the activeTimelock is reset to type(uint256).max but the proposedMainTeam and proposedConfirmationTeam is not reset. 
So, the changeTeams can't be called due to block.timestamp >= activeTimelock and new proposal can't be called due to require( proposedMainTeam == address(0), "Cannot overwrite non-zero proposed mainTeam." );. Thus the mechanism gets stuck.

Consider the following situation.

1. The mainTeam wants to make some modifications, and he calls proposeTeams.
2. The confirmationTeam rejects the proposal by sending 0.01 ETH to the contract.
3. No one can call changeTeams.
The mainTeam can't call proposeTeams.

### Solution: 2
[There is a timelock of 30 days before the proposed mainTeam can confirm the change.](https://github.com/DeFiHackLabs-BootCamp/Fall-HW5/blob/main/hw/src/week5_team/Team.sol#L7)
Consider the following scenario.

1. The confirmationTeam immediately sends 0.05 or more ether to the ManagedTeam upon deployment.
2. The activeTimelock is triggered.
3. The time from proposeTeams to changeTeams is less than expected.

There is no restriction here that the mainTeam cannot be the same as the confirmationTeam.
If mainTeam==confirmationTeam
It is possible to immediately activate the activeTimelock after deploy.
proposeTeams() to changeTeams() process can less than 30 days

## 🥚 Easter egg 🥚 
This week's hw are drawn from the findings of TaiChi's Audit Group white hats. 
Feel free to check out the full details [1](https://github.com/TaiChiAuditGroup/Portfolio/blob/main/Code4rena/2024-01-saltyio/2024-01-saltyio.md#m-03--once-rejected-no-new-proposal-could-be-created-for-managedwallet), [2](https://github.com/TaiChiAuditGroup/Portfolio/blob/main/Code4rena/2024-01-saltyio/2024-01-saltyio.md#m-01--timelock-can-be-bypass) !