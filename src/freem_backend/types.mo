import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
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
}