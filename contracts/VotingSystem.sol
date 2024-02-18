// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract VotingSystem {
    struct Voting {
        address owner;
        uint votingId;
        Choice[] choices;
        uint startTime;
        uint endTime;
        bool locked;
        // uint lastChoiceId;
    }

    struct Choice {
        uint choiceId;
        string description;
        uint votesCount;
    }
    uint blockchainCreatedTime;

    event VotingAdded(address indexed owner, uint indexed votingId, uint startTime, uint endTime);
    event VotingRemoved(address indexed owner, uint indexed votingId);
    event ChoiceAdded(uint indexed votingId, uint indexed choiceId, string description);
    event VoteAdded(address indexed user, uint indexed votingId, uint indexed choiceId);
    event BlockchainCreated();
    

    mapping (address => mapping (uint => bool)) userChoices;
    mapping (address => mapping (uint => bool)) userVotes;
    Voting[] private votings;
    uint private lastVotingId = 0;
    uint private lastChoiceId = 0;
    
    constructor(){
        blockchainCreatedTime = block.timestamp;
        emit BlockchainCreated();
    }

    modifier onlyOwnerOfVoting (address user, uint votingId){
        require(votings[votingId].owner == user, "You are not owner of this voting!");
        _;
    }

    modifier notLocked(uint votingId) {
        require(!votings[votingId].locked, "Voting is locked and cannot be modified!");
        _;
    }

    modifier votingInProgress(uint votingId) {
        require(block.timestamp < votings[votingId].endTime, "Voting has ended!");
        _;
    }

    function addVotings(address owner, Voting calldata voting, uint durationSeconds) public returns (bool) {
        require(voting.choices.length > 0, "Choices array can not be empty");
        require(owner != address(0), "Owner address is not correct or not valid");
        Voting memory newVoting;
        newVoting.owner = owner;
        newVoting.votingId = ++lastVotingId;
        // newVoting.lastChoiceId = 0;
        Choice[] memory choices = new Choice[](voting.choices.length);
        newVoting.startTime = block.timestamp;
        newVoting.endTime = block.timestamp + durationSeconds;

        newVoting.locked = (block.timestamp >= newVoting.startTime && block.timestamp <= newVoting.endTime);

        // Choice[] storage choices;

        for (uint i = 0; i < voting.choices.length; i++){          
            // newVoting.choices[i].choiceId = ++newVoting.lastChoiceId;
            // newVoting.choices[i].choiceId = ++newVoting.lastChoiceId;
            // newVoting.choices[i].votesCount = 0;
            // choices[i].choiceId = ++newVoting.lastChoiceId;
            // choices[i].choiceId = ++lastChoiceId;

            // choices[i].votesCount = 0;  
            require(bytes(voting.choices[i].description).length > 0, "Description should be not empty");
            
            // Choice memory choice = Choice(++lastChoiceId, voting.choices[i].description, 0); 
            choices[i] = Choice(++lastChoiceId, voting.choices[i].description, 0);
            emit ChoiceAdded(newVoting.votingId, choices[i].choiceId, choices[i].description);
        }
        newVoting.choices = choices;

        votings.push(voting);
        emit VotingAdded(owner, newVoting.votingId, newVoting.startTime, newVoting.endTime);

        return true;
    }

    function getAllVotings() public view returns (Voting[] memory){
        return votings;
    }

    function getVotingByVotingId(uint votingId) public view returns (Voting memory){
        require(votingId > votings.length - 1 , "Voting with this id does not exist!");
        return votings[votingId];
    }

   function removeVoting(address user, uint votingId) public onlyOwnerOfVoting(user, votingId) returns (bool) {
        require(votingId < votings.length, "Voting with this id does not exist");
        require(!votings[votingId].locked, "Voting is locked and cannot be removed!");
        votings[votingId] = votings[votings.length - 1];
        votings.pop();
        emit VotingRemoved(user, votingId);

        return true;
    }

    modifier choiceNotExist (address user, uint votingId, uint choiceId) {
        // Voting memory voting = votings[votingId];
        // Choice memory choice = votings[votingId].choices[choiceId].choiceId;
        require(!userChoices[user][choiceId], "You have already make a choice in this voting!");
        _;
    }

    modifier notVoted (address user, uint votingId) {
        require(!userVotes[user][votingId], "You have already voted in this voting!");
        _;
    }

    function addChoiceToExistedVoting(address user, uint votingId, uint choiceId)
        public
        notVoted(user, votingId) 
        choiceNotExist(user, votingId, choiceId) 
        notLocked(votingId)
        votingInProgress(votingId)
        returns (bool) {
        if (block.timestamp > votings[votingId].endTime) {
            votings[votingId].locked = true;
        }
        
        votings[votingId].choices[choiceId].votesCount = votings[votingId].choices[choiceId].votesCount + 1;
        userChoices[user][choiceId] = true;
        userVotes[user][votingId] = true;
        emit VoteAdded(user, votingId, choiceId);
        return true;
    } // problem is that 

    function addChoicesForVotes() public {

    }
}