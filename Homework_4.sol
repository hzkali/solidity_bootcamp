// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProposalContract {
    address public owner; // Contract owner's address

    uint256 private counter;
    address[] private voted_addresses; // Array to store addresses that have voted

    // Proposal structure to store proposal details
    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    // Mapping to store proposal history
    mapping(uint256 => Proposal) proposal_history;

    // Modifier to restrict function access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to check if the proposal is active
    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    // Modifier to check if the voter has not voted before
    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
        _;
    }

    // Constructor to set the contract owner during deployment and add the owner to voted_addresses
    constructor() {
        owner = msg.sender; // Set the owner to the address that deployed the contract
        voted_addresses.push(owner); // Add the owner to the voted_addresses array
    }

    // Function to create a new proposal, restricted to the owner
    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
    }

    // Function to set the owner of the contract, restricted to the current owner
    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    // Voting function with active modifier, preventing multiple votes from the same address, and resetting voted_addresses
    function vote(uint8 choice) external active newVoter(msg.sender) {
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            // Reset voted_addresses with only the owner
            voted_addresses = [owner];
        }
    }

    // Placeholder for the calculateCurrentState function
    function calculateCurrentState() private view returns (bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;

        if (proposal.pass % 2 == 1) {
            pass += 1;
        }

        pass = pass / 2;

        if (approve > reject + pass) {
            return true;
        } else {
            return false;
        }
    }

    // Function to check if the address has voted before
    function isVoted(address voter) internal view returns (bool) {
        for (uint256 i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == voter) {
                return true; // Voter has already voted
            }
        }
        return false; // Voter has not voted
    }
}
