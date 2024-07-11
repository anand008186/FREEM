import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
module {

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
        logo : Text;
        numberOfMembers : Nat;
    };

    public type Role = {
        #Challenger;
        #AssetHolder;
        #Admin;
    };

    public type Member = {
        name : Text;
        role : Role;
    };

    public type Incentive = {
      id: Nat;
      description: Text;
      rewardTokenName: Text; // Name of the token given as a reward
      rewardAmount: Nat; // Amount of tokens given as a reward
    };

    public type Challenge = {
      id: Nat;
      name: Text;
      description: Text;
      stakeAmount: Float; // Minimum stake amount required to join the challenge
      startDate: Text;
      endDate: Text;
      participants: [UserToken]; // Tracks tokens for each participant
      totalStakedAmount: Nat; // Total amount of tokens currently staked in the challenge
      incentives: [Incentive]; // List of incentives available in the challenge
    };

    public type ProposalId = Nat;

    public type ProposalContent = {
        #ChangeManifesto : Text; // Change the challenge manifesto to the provided text
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