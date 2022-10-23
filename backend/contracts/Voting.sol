// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol"; //countig the voters
import "hardhat/console.sol";

contract Voting {
    using Counters for Counters.Counter;
    Counters.Counter public _voterId;
    Counters.Counter public _candidateId;
    address public electionCommission; //owner

    //candidate
    struct Candidate {
        uint256 candidateId;
        string age;
        string name;
        string image;
        uint256 voteCount;
        address candidateAddress;
        string ipfs;
        //ipfs contain all the info about sigle candidate
        //we upload entire data of this candidate to the ipfs
        //from that ipfs link we can fetch all info.
    }

    event CreateCandidate(
        uint256 indexed candidateId,
        string age,
        string name,
        string image,
        uint256 voteCount,
        address candidateAddress,
        string ipfs
    );

    address[] public allCandidateAddress;
    mapping(address => Candidate) public allCandidates;

    //voter
    struct Voter {
        uint256 voterId;
        string age;
        string name;
        string image;
        address voterAddress;
        uint256 allowed; //0 means not voted 1 means voted and registered so he cant vote
        bool voted;
        uint256 vote;
        string ipfs;
    }

    event CreateVoter(
        uint256 indexed voterId,
        string name,
        string age,
        string image,
        address voterAddress,
        uint256 allowed,
        bool voted,
        uint256 vote,
        string ipfs
    );

    address[] public votedVoters;
    address[] public allVotersAddress;
    mapping(address => Voter) public allVoters;

    constructor() {
        electionCommission = msg.sender;
    }

    function setCandidate(
        string memory _age,
        string memory _name,
        string memory _image,
        address _candidateAddress,
        string memory _ipfs
    ) public {
        require(
            electionCommission == msg.sender,
            "Only Election Commission can set the candidate !!!"
        );
        _candidateId.increment(); //inc function from counter package
        uint256 canId = _candidateId.current();
        Candidate storage candidate = allCandidates[_candidateAddress];

        candidate.candidateId = canId;
        candidate.age = _age;
        candidate.name = _name;
        candidate.image = _image;
        candidate.voteCount = 0; //initially
        candidate.candidateAddress = _candidateAddress;
        candidate.ipfs = _ipfs;

        //pushing the candidate address into allCandidateAddress array
        allCandidateAddress.push(_candidateAddress);

        //emitting the event
        emit CreateCandidate(
            canId,
            _age,
            _name,
            _image,
            candidate.voteCount,
            _candidateAddress,
            _ipfs
        );
    }

    //get candidate
    function getAllCandidates() public view returns (address[] memory) {
        return allCandidateAddress;
    }

    //get number of candidate
    function noOfCandidate() public view returns (uint256) {
        return allCandidateAddress.length;
    }

    //get single candidate data
    function getSingleCandidateData(address _address)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            uint256,
            address,
            string memory
        )
    {
        return (
            allCandidates[_address].candidateId,
            allCandidates[_address].age,
            allCandidates[_address].name,
            allCandidates[_address].image,
            allCandidates[_address].voteCount,
            allCandidates[_address].candidateAddress,
            allCandidates[_address].ipfs
        );
    }

    //create voter who can vote
    function createVoter(
        string memory _age,
        string memory _name,
        string memory _image,
        string memory _ipfs,
        address _address
    ) public {
        require(
            electionCommission == msg.sender,
            "Only Election Commission can issue the voters !!!"
        );
        _voterId.increment(); //inc function from counter package

        uint256 voterIdNumber = _voterId.current();
        Voter storage voter = allVoters[_address];

        require(
            voter.allowed == 0,
            "Voter already voted in the election ,cant vote twice !!!"
        );

        voter.name = _age;
        voter.name = _name;
        voter.image = _image;
        voter.ipfs = _ipfs;
        voter.voterAddress = _address;
        voter.voterId = voterIdNumber;
        voter.vote = 1000;
        voter.voted = false;

        //registered
        voter.allowed = 1;

        //pushing the voter address into allvoterAddress array
        allVotersAddress.push(_address);

        //emitting the event
        emit CreateVoter(
            voterIdNumber,
            _name,
            _age,
            _image,
            _address,
            voter.voted,
            voter.vote,
            _ipfs,
            voter.allowed
        );
    }
}
