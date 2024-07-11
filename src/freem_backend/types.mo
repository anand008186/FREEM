import Principal "mo:base/Principal";

module {

public type Token = {
  name: Text;
  challengeId: Nat; // Associate the token with a specific challenge
};

public type UserToken = {
  user: Principal;
  tokens: [(Token, Nat)]; // A list of tuples, each containing a Token and the quantity owned
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

public type Pool = {
  name: Text;
  creator: Principal;
  stake: Nat; // Minimum stake amount in $Fitness tokens required to join the pool
  totalStaked: Nat; // Total amount of tokens currently staked in the pool
  members: [UserToken]; // Members who have joined the pool and their staked tokens
  stakeTokenName: Text; // Type of token required for staking (e.g., $Fitness)
  incentiveTokenName: Text; // Type of token given as incentives (e.g., $Burpee)
  incentives: [Incentive]; // List of incentives available in the pool
};
}