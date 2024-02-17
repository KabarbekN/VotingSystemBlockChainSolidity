const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('VotingSystem Contract', function () {
  let VotingSystem;
  let votingSystem;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    VotingSystem = await ethers.getContractFactory('VotingSystem');
    [owner, addr1, addr2] = await ethers.getSigners();
    votingSystem = await VotingSystem.deploy();
    await votingSystem.deployed();
  });

  describe('Deployment', function () {
    it('Should set the correct owner', async function () {
      expect(await votingSystem.owner()).to.equal(owner.address);
    });

    it('Should initialize lastVotingId and lastChoiceId to zero', async function () {
      expect(await votingSystem.lastVotingId()).to.equal(0);
      expect(await votingSystem.lastChoiceId()).to.equal(0);
    });
  });

  describe('addVotings function', function () {
    it('Should add a new voting', async function () {
      await votingSystem.addVotings(addr1.address, /* add parameters */);

      const votings = await votingSystem.getAllVotings();
      expect(votings.length).to.equal(1);
      // Add more assertions as needed
    });

    it('Should not allow empty choices array', async function () {
      await expect(
        votingSystem.addVotings(addr1.address, /* empty choices array */)
      ).to.be.revertedWith('Choices array can not be empty');
    });

    // Add more test cases for addVotings function
  });

  describe('removeVoting function', function () {
    it('Should remove a voting', async function () {
      await votingSystem.addVotings(addr1.address, /* add parameters */);
      await votingSystem.removeVoting(addr1.address, /* add votingId */);

      const votings = await votingSystem.getAllVotings();
      expect(votings.length).to.equal(0);
      // Add more assertions as needed
    });

    it('Should revert if voting is locked', async function () {
      await votingSystem.addVotings(addr1.address, /* add parameters */);
      // Lock the voting

      await expect(
        votingSystem.removeVoting(addr1.address, /* add votingId */)
      ).to.be.revertedWith('Voting is locked and cannot be removed!');
    });

    // Add more test cases for removeVoting function
  });

  // Add more describe blocks for other functions and modifiers as needed
});
