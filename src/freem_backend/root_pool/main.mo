import Result "mo:base/Result";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Int "mo:base/Int";
import Hash "mo:base/Hash";

import Types "./types";

actor {

        type Result<A, B> = Result.Result<A, B>;
        type Member = Types.Member;
        type ProposalContent = Types.ProposalContent;
        type ProposalId = Types.ProposalId;
        type Proposal = Types.Proposal;
        type Role = Types.Role;
        type Vote = Types.Vote;
        type DAOStats = Types.DAOStats;
        type HttpRequest = Types.HttpRequest;
        type HttpResponse = Types.HttpResponse;
        type ChallengeId = Types.ChallengeId;
        type Token = Types.Token;
        type Incentive = Types.Incentive;
        type Challenge = Types.Challenge;
        type Pool = Types.Pool;
        type ChallengeArg = Types.ChallengeArg;

        // The principal of the Webpage canister associated with this DAO canister (needs to be updated with the ID of your Webpage canister)
        stable let canisterIdWebpage : Principal = Principal.fromText("u72sn-7aaaa-aaaab-qadkq-cai");

        stable var manifesto : Text = "This is the incentive pool for people taking on pushup challenges";
        stable let name = "Promise";

        var incentives : Buffer.Buffer<Incentive> = Buffer.Buffer<Incentive>(2);
        // List of challenges
        var challenges : [Challenge] = [];

        var pools : [Pool] = []; // List of pools

        //token registration when new pool is created
        var tokens : [Token] = [];

        // token balances
        let balances : HashMap.HashMap<Principal, HashMap.HashMap<Text, Nat>> = HashMap.HashMap<Principal, HashMap.HashMap<Text, Nat>>(0, Principal.equal, Principal.hash);

        // Function to create a new challenge
        var challengeId : Nat = 0;

        let members = HashMap.HashMap<Principal, Types.Member>(1, Principal.equal, Principal.hash);

        // Add Initial mentor for DAO
        let initialAdmin : Types.Member = {
                name = "motoko_bootcamp";
               stakedAmount =2;
        };
        members.put(Principal.fromText("nkqop-siaaa-aaaaj-qa3qq-cai"), initialAdmin);

        var nextProposalId : ProposalId = 0;
        let proposals = HashMap.HashMap<ProposalId, Proposal>(0, Nat.equal, Hash.hash);

        /*
        let tokenCanister = actor("jaamb-mqaaa-aaaaj-qa3ka-cai") : actor { // actor("jaamb-mqaaa-aaaaj-qa3ka-cai") : actor {
                mint : shared (owner : Principal, amount : Nat) -> async Result<(), Text>;
                burn : shared (owner : Principal, amount : Nat) -> async Result<(), Text>;
                balanceOf : shared (owner : Principal) -> async Nat;
        };*/

        // Returns the name of the DAO
        public shared query func getName() : async Text {
                return name;
        };

        // Returns the manifesto of the DAO
        public shared query func getManifesto() : async Text {
                return manifesto;
        };

        // Returns the Principal ID of the Webpage canister associated with this DAO canister
        public query func getIdWebpage() : async Principal {
                return canisterIdWebpage;
        };

        public query func getStats() : async DAOStats {

                return ({
                        name;
                        manifesto;
                        incentives = Buffer.toArray(incentives);
                        members = Iter.toArray(Iter.map<Member, Text>(members.vals(), func(member : Member) { member.name }));
                        numberOfMembers = members.size();
                });
        };

        // Returns the incentives of the DAO
        public shared query func getIncentives() : async [Incentive] {
                return Buffer.toArray<Incentive>(incentives);
        };

        public shared ({ caller }) func createChallenge(challengeArg : ChallengeArg) : async () {

                //  Validate Input
                assert (challengeArg.CreatorStakedAmount >= 1);
                assert (challengeArg.incentiveTokenName != "");

                //deposit the stake amount from the creator to the canister

                // make the creator a member of the challenge
                let newMember : Member = {
                        name = challengeArg.CreatorName;
                        stakedAmount = challengeArg.CreatorStakedAmount;
                };
                let _members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);
                _members.put(caller, newMember);
                members.put(caller, newMember);
                // create a new challenge
                let newChallenge : Challenge = {
                        id = challengeId;
                        name = challengeArg.name;
                        creator = newMember;
                        description = challengeArg.description;
                        memberStakeAmount = challengeArg.memberStakeAmount;
                        members = _members;
                        startDate = Time.now();
                        endDate = Time.now() + 60 * 60 * 24 * 30 * 1_000_000_000; // 7 days from now
                        totalStakedAmount = challengeArg.CreatorStakedAmount;
                        incentiveTokenName = challengeArg.incentiveTokenName;
                };
                // add the challenge to the list
                let buffer = Buffer.fromArray<Challenge>(challenges);
                buffer.add(newChallenge);
                challenges := Buffer.toArray<Challenge>(buffer);

                // create a predefined list of incentives
                incentives.add({ description = "#1 : Do 10 pushups and get 10 points"; rewardTokenName = "$Fitness"; rewardAmount = 10} );
              
                // create a new token
                let newToken : Token = {
                        name = challengeArg.incentiveTokenName;
                        challengeId = challengeId;
                };

                // add the token to the token list
                let _buffer = Buffer.fromArray<Token>(tokens);
                _buffer.add(newToken);
                tokens := Buffer.toArray<Token>(_buffer);

                // increment the challenge id
                challengeId += 1;

        };

        // Register a new member in the DAO with the given name and principal of the caller
        // Airdrop 10 MBC tokens to the new member
        // New members are always Challenger
        // Returns an error if the member already exists
        public shared ({ caller }) func registerMember(member : Member) : async Result<(), Text> {
                if (Principal.isAnonymous(caller)) {
                        // We don't want to register the anonymous identity
                        return #err("Cannot register member with the anonymous identity");
                };

                let optFoundMember : ?Member = members.get(caller);
                switch (optFoundMember) {
                        // Check if n is null
                        case (null) {
                                members.put(caller, member);
                                // TODO : mint 10 MBT for new member
                                //let mintResult = await tokenCanister.mint(caller, 10);

                                // TODO : Get a deposit address for the new member and store it for future withdrawal
                                //return mintResult;
                                return #ok(()); 
                        };
                        case (?optFoundMember) {
                                return #err("Member already exists");
                        };
                };
        };

        // Function to create a new pool
        public shared ({ caller }) func createPool(poolName : Text, stake : Nat, stakeTokenName : Text, incentiveTokenName : Text) : async () {
                // Implementation to create a new pool within a challenge
                // Validate input
                assert (stakeTokenName != "");
                assert (incentiveTokenName != "");

                // check whether the caller is a member of the primary challenge
                switch (members.get(caller)) {
                        case (?member) {
                                // make the creator a member of the pool
                                let newMember : Member = {
                                        name = member.name;
                                        stakedAmount = stake;
                                };
                                let _members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);
                                _members.put(caller, newMember);
                                // create a new pool
                                let newPool : Pool = {
                                        id = challengeId;
                                        name = poolName;
                                        creator = newMember;
                                        stake = stake;
                                        totalStaked = stake;
                                        members = _members;
                                        stakeTokenName = stakeTokenName;
                                        incentiveTokenName = incentiveTokenName;
                                };
                                // add the pool to the list
                                let buffer = Buffer.fromArray<Pool>(pools);
                                buffer.add(newPool);
                                pools := Buffer.toArray<Pool>(buffer);
                        };
                        case (null) {
                                // Caller is not a member of the primary challenge
                                return;
                        };
                };

        };

        // Get the member with the given principal
        // Returns an error if the member does not exist
        public query func getMember(p : Principal) : async Result<Member, Text> {
                switch (members.get(p)) {
                        // Check if n is null
                        case (null) { return #err("Member not found") };
                        case (?optFoundMember) { return #ok(optFoundMember) };
                };
        };

        // this function takes no parameters and returns the list of members of your DAO as an Array
        public query func getAllMembers() : async [Member] {
                return Iter.toArray<(Member)>(members.vals());
        };

        // this function takes no parameters and returns the number of members of your DAO as a Nat.
        public query func numberOfMembers() : async Nat {
                return members.size();
        };

        // Create a new proposal and returns its id
        // Returns an error if the caller is not a mentor or doesn't own at least 1 MBC token
        public shared ({ caller }) func createProposal(content : ProposalContent,id: ChallengeId) : async Result<ProposalId, Text> {
                switch (members.get(caller)) {
                        case (null) {
                                return #err("The caller is not a member");
                        };
                        case (?member) {
                                //let balance = await tokenCanister.balanceOf(caller);
                                /* // TODO : We need to burn at least one token to avoid proposal spamming among challengers
                        if ( Result.isErr( await tokenCanister.burn(caller, 1) ) ) {
                                return #err("The caller does not have enough tokens to create a proposal");
                        };*/
                                // Create the proposal and burn the tokens
                                let proposal : Proposal = {
                                        id = nextProposalId;
                                        challengeId = id;
                                        content;
                                        creator = caller;
                                        created = Time.now();
                                        executed = null;
                                        votes = [];
                                        voteScore = 0;
                                        status = #Open;
                                };
                                proposals.put(nextProposalId, proposal);
                                nextProposalId += 1;

                                return #ok(nextProposalId - 1);
                        };
                };
        };

        // Get the proposal with the given id
        // Returns an error if the proposal does not exist
        public query func getProposal(id : ProposalId) : async Result<Proposal, Text> {
                switch (proposals.get(id)) {
                        case (null) { return #err("Proposal doesn't exist") };
                        case (?proposal) { return #ok(proposal) };
                };
        };

        // Returns all the proposals
        public query func getAllProposal() : async [Proposal] {
                return Iter.toArray(proposals.vals());
        };

        // Vote for the given proposal
        // Returns an error if the proposal does not exist or the member is not allowed to vote
        public shared ({ caller }) func voteProposal(proposalId : ProposalId, vote : Vote) : async Result<(), Text> {

                // Check if the caller is a member of the DAO
                switch (members.get(caller)) {
                        case (null) {
                                return #err("The caller is not a member - cannot vote one proposal");
                        };
                        case (?member) {
                                // Check if the proposal exists
                                switch (proposals.get(proposalId)) {
                                        case (null) {
                                                return #err("The proposal does not exist");
                                        };
                                        case (?proposal) {
                                                // Check if the proposal is open for voting
                                                if (proposal.status != #Open) {
                                                        return #err("The proposal is not open for voting");
                                                };
                                                // Check if the caller has already voted
                                                if (_hasVoted(proposal, caller)) {
                                                        return #err("The caller has already voted on this proposal");
                                                };
                                                let balance = 1; // await tokenCanister.balanceOf(caller); // TODO : Consider user's token balance as part of voting power?
                                                let multiplierVote = switch (vote.yesOrNo) {
                                                        case (true) { 1 };
                                                        case (false) { -1 };
                                                };
                                                let multiplierRole = 1;
                                                let votingPower = balance * multiplierVote * multiplierRole;
                                                let newVoteScore = proposal.voteScore + votingPower;
                                                var newExecuted : ?Time.Time = null;
                                                let newVote : Vote = {
                                                        member = caller;
                                                        votingPower = Int.abs(votingPower);
                                                        yesOrNo = vote.yesOrNo;
                                                };
                                                var newVotes : Buffer.Buffer<Vote> = Buffer.fromArray<Vote>(proposal.votes); //.append( Buffer.fromArray<Vote>([newVote]) );
                                                newVotes.add(newVote);

                                                let newStatus = if (newVoteScore >= 100) {
                                                        #Accepted;
                                                } else if (newVoteScore <= -100) {
                                                        #Rejected;
                                                } else {
                                                        #Open;
                                                };
                                                switch (newStatus) {
                                                        case (#Accepted) {
                                                                let resultExec : Result<(), Text> = await _executeProposal(proposal.content);
                                                                if (Result.isErr(resultExec)) {
                                                                        return resultExec;
                                                                };
                                                                newExecuted := ?Time.now();
                                                        };
                                                        case (_) {
                                                                return #ok();
                                                        };
                                                };

                                                let newProposal : Proposal = {
                                                        id = proposal.id;
                                                        challengeId = proposal.challengeId;
                                                        content = proposal.content;
                                                        creator = proposal.creator;
                                                        created = proposal.created;
                                                        executed = newExecuted;
                                                        votes = Buffer.toArray(newVotes);
                                                        voteScore = newVoteScore;
                                                        status = newStatus;
                                                };
                                                proposals.put(proposal.id, newProposal);
                                                return #ok();
                                        };
                                };
                        };
                };
        };

        func _hasVoted(proposal : Proposal, member : Principal) : Bool {
                return Array.find<Vote>(
                        proposal.votes,
                        func(vote : Vote) {
                                return vote.member == member;
                        },
                ) != null;
        };

        func _executeProposal(content : ProposalContent) : async Result<(), Text> {
                switch (content) {
                        case (#AddIncentive(newIncentive)) {
                                // incentives.add(newIncentive);
                                return #ok();
                        };
                        case (_) {
                               return #ok();
                        };
                };
        };

};
