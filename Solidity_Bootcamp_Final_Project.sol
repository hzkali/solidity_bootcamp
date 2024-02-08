// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProposalContract {
    // Owner
    address public owner;
    
    // Proposal counter
    uint256 private counter;

    // Proposal structure
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

    // Array to store addresses that have voted
    mapping(address => bool) private voted_addresses;

    // Constructor to set the owner and initialize voted_addresses
    constructor() {
        owner = msg.sender;
        voted_addresses[owner] = true;
    }

    // Modifier to restrict function access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to check if the proposal is active
    modifier active() {
        require(proposal_history[counter].is_active, "The proposal is not active");
        _;
    }

    // Modifier to check if the voter has not voted before
    modifier newVoter() {
        require(!voted_addresses[msg.sender], "Address has already voted");
        _;
    }

    // Execute Functions

    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
    }

    function vote(uint8 choice) external active newVoter {
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses[msg.sender] = true;

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
            voted_addresses[msg.sender] = false;
        }
    }

    function terminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }

    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];
        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;

        if (proposal.pass % 2 == 1) {
            pass += 1;
        }

        pass = pass / 2;

        return approve > reject + pass;
    }


    function isVoted(address _address) external view returns (bool) {
        return voted_addresses[_address];
    }

    function getCurrentProposal() external view returns (Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns (Proposal memory) {
        return proposal_history[number];
    }
}
