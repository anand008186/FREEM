import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
module {

public type ChallengeId = Nat;

public type Token = {
  name: Text;
  challengeId: Nat; // Associate the token with a specific challenge
};

public type Member = {
  name: Text;
  stakedAmount: Nat;
};
public type Incentive = {
  description: Text;
  rewardAmount: Nat; // Amount of tokens given as a reward
};

public type Challenge = {
  id: ChallengeId;
  name: Text;
  creator: Member;
  description: Text;
  memberStakeAmount: Float;
  members: HashMap.HashMap<Principal,Member>; // Minimum stake amount required to join the challenge
  startDate: Time.Time;
  endDate: Time.Time;
  totalStakedAmount: Nat;
  incentiveTokenName: Text;        // Total amount of tokens currently staked in the challenge
};

public type ChallengeArg = {
  name: Text;
  description: Text;
  memberStakeAmount: Float;
  CreatorName: Text;
  CreatorStakedAmount: Nat;
  incentiveTokenName: Text;
  
};

public type Pool = {
  id: ChallengeId;
  name: Text;
  creator: Member;
  stake: Nat; // Minimum stake amount in $Fitness tokens required to join the pool
  totalStaked: Nat; // Total amount of tokens currently staked in the pool
  members: HashMap.HashMap<Principal,Member>; // Members who have joined the pool and their staked tokens
  stakeTokenName: Text; // Type of token required for staking (e.g., $Fitness)
  incentiveTokenName: Text; // Type of token given as incentives (e.g., $Burpee)

};

    public type PromiseStatus = {
        #Ready;
        #Running;
        #Ended;
        #Distribution;
    };

    public type DAOStats = {
        name : Text;
        manifesto : Text;
        incentives : [Incentive];
        members : [Text];
        numberOfMembers : Nat;
    };

    public type Role = {
        #Challenger;
        #AssetHolder;
        #Admin;
    };


    public type ProposalId = Nat;

    public type ProposalContent = {
        #AddIncentive : Incentive;
        #AddAdmin : Principal; // Upgrade the member to a mentor with the provided principal
    };

    public type ProposalStatus = {
        #Open;
        #Accepted;
        #Rejected;
    };

    public type Vote = {
        member : Principal; // The member who voted
        votingPower : Nat;
        yesOrNo : Bool; // true = yes, false = no
    };

    public type Proposal = {
        id : ProposalId; // The unique identifier of the proposal
        challengeId: Nat;
        content : ProposalContent; // The content of the proposal
        creator : Principal; // The member who created the proposal
        created : Time.Time; // The time the proposal was created
        executed : ?Time.Time; // The time the proposal was executed or null if not executed
        votes : [Vote]; // The votes on the proposal so far
        voteScore : Int; // The current score of the proposal based on the votes
        status : ProposalStatus; // The current status of the proposal
    };

    public type HeaderField = (Text, Text);
    public type HttpRequest = {
        body : Blob;
        headers : [HeaderField];
        method : Text;
        url : Text;
    };

    public type HttpResponse = {
        body : Blob;
        headers : [HeaderField];
        status_code : Nat16;
        streaming_strategy : ?StreamingStrategy;
    };

    public type StreamingStrategy = {
        #Callback : {
            callback : StreamingCallback;
            token : StreamingCallbackToken;
        };
    };

    public type StreamingCallback = query (StreamingCallbackToken) -> async (StreamingCallbackResponse);

    public type StreamingCallbackToken = {
        content_encoding : Text;
        index : Nat;
        key : Text;
    };

    public type StreamingCallbackResponse = {
        body : Blob;
        token : ?StreamingCallbackToken;
    };
};