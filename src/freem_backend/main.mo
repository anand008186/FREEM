import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Types "./types";
import icrcTypes "./icrc";
actor Freem {

type ChallengeId = Types.ChallengeId;
type Token = Types.Token;
type Member = Types.Member;
type Incentive = Types.Incentive;
type Challenge = Types.Challenge;
type Pool = Types.Pool;

type ChallengeArg = Types.ChallengeArg;
type Result<A, B> = Result.Result<A, B>;
// Token canister(ICRC2) types
type ICRCTransferError = icrcTypes.ICRCTransferError;
type ICRCTokenTxReceipt = icrcTypes.ICRCTokenTxReceipt;
type ICRCMetaDataValue = icrcTypes.ICRCMetaDataValue;
type ICRCAccount = icrcTypes.ICRCAccount;
type Subaccount = icrcTypes.Subaccount;
type ICRC2TransferArg = icrcTypes.ICRC2TransferArg;
type ICRCTransferArg = icrcTypes.ICRCTransferArg;
type ICRC2TokenActor = icrcTypes.ICRC2TokenActor;
type ICRC2AllowanceArgs = icrcTypes.ICRC2AllowanceArgs;
type ICRC2Allowance = icrcTypes.ICRC2Allowance;


// List of challenges
var challenges: [Challenge] = [];

var pools: [Pool] = []; // List of pools

//token registration when new pool is created
var tokens : [Token] = [];

let primaryPoolMembers : HashMap.HashMap<Principal,Member> = HashMap.HashMap<Principal,Member>(0,Principal.equal,Principal.hash);

// token balances
let balances : HashMap.HashMap<Principal,HashMap.HashMap<Text,Nat>> = HashMap.HashMap<Principal, HashMap.HashMap<Text,Nat>>(0,Principal.equal,Principal.hash);

//Incentive addition
let Incentives : HashMap.HashMap<Text, [Incentive]> = HashMap.HashMap<Text, [Incentive]>(0, Text.equal, Text.hash);

// Function to create a new challenge
var challengeId: Nat = 0;
public shared({caller}) func createChallenge(challengeArg: ChallengeArg): async ()  {
  
    //  Validate Input
    assert(challengeArg.CreatorStakedAmount >= 1);
    assert(challengeArg.incentiveTokenName != "");

    //deposit the stake amount from the creator to the canister

  // make the creator a member of the challenge
    let newMember: Member = {
        name = challengeArg.CreatorName;
        stakedAmount = challengeArg.CreatorStakedAmount;
    };
    let _members = HashMap.HashMap<Principal,Member>(0,Principal.equal,Principal.hash);
    _members.put(caller,newMember);
    primaryPoolMembers.put(caller,newMember);
    // create a new challenge
    let newChallenge: Challenge = {
        id = challengeId;
        name = challengeArg.name;
        creator = newMember;
        description = challengeArg.description;
        memberStakeAmount = challengeArg.memberStakeAmount;
        members = _members;
        startDate = Time.now();
        endDate =Time.now() + 60 * 60 * 24 * 30* 1_000_000_000; // 7 days from now
        totalStakedAmount = challengeArg.CreatorStakedAmount;
        incentiveTokenName = challengeArg.incentiveTokenName;
    };
    // add the challenge to the list
    let buffer = Buffer.fromArray<Challenge>(challenges);
    buffer.add(newChallenge);
    challenges := Buffer.toArray<Challenge>(buffer);


     // create a predefined list of incentives
    let incentives: [Incentive] = [
        { description = "First 50 Push Ups"; rewardAmount = 40; },
    ];
    Incentives.put(challengeArg.incentiveTokenName, incentives);

    // create a new token
    let newToken: Token = {
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

// Function to earn $VALUE tokens
public shared({caller}) func earnValueTokens(member: Principal, amount: Nat): async () {
  // Implementation to credit $VALUE tokens to a member
};

// Function to transfer $VALUE tokens between members
// public shared({caller}) func transferValueTokens( to: Principal, amount:Nat , tokenName:Text): async Result<(),Text> {
   

//   //check if the tokenName is primary incentive token
//   let _challenge = Array.find(challenges, func(t:Challenge): Bool { t.incentiveTokenName == tokenName });
//   //if token is not found in primary challenge, search in pools
//   switch(_challenge){
//     case(null){
//        let _pool= Array.find(pools, func(t:Pool) : Bool { t.incentiveTokenName == tokenName });
//      switch(_pool){
//        case(null){
//          return #err("Token not found in the challenge or pool");
//        };
//        case(?pool){
//          let _from = Array.find(_pool.members, func(t:HashMap.HashMap<Principal,Member>) { t.get(caller) });
//          let _to = Array.find(_pool.members, func(t:HashMap.HashMap<Principal,Member>) { t.get(to) });
//          if((_from == null) or (_to == null)){
//            return #err("Caller or recipient not found in the pool");
//          };
//          let _balance = balances.get(caller).get(tokenName);
//          if(_balance < amount){
//            return #err("Insufficient balance");
//          };
//          balances.get(caller).put(tokenName,_balance - amount);
//          balances.get(to).put(tokenName,balances.get(to).get(tokenName) + amount);
//          return #ok(());
//        };
//      };
   
//     };
//     case(?_challenge){
//       let _from = Array.find(_challenge.members, func(t:HashMap.HashMap<Principal,Member>) { t.get(caller) });
//       let _to = Array.find(_challenge.members, func(t:HashMap.HashMap<Principal,Member>) :Bool { t.get(to) });
//       if((_from == null) or (_to == null)){
//         return #err("Caller or recipient not found in the challenge");
//       };
//       let _balance = balances.get(caller).get(tokenName);
//       if(_balance < amount){
//         return #err("Insufficient balance");
//       };
//       balances.get(caller).put(tokenName,_balance - amount);
//       balances.get(to).put(tokenName,balances.get(to).get(tokenName) + amount);
//       return #ok(());

//     };

// };
// };

// Function to create a new pool
public shared({caller}) func createPool( poolName: Text, stake: Nat,stakeTokenName:Text, incentiveTokenName:Text): async () {
    // Implementation to create a new pool within a challenge
    // Validate input
    assert(stakeTokenName != "");
    assert(incentiveTokenName != "");

    // check whether the caller is a member of the primary challenge
    switch(primaryPoolMembers.get(caller)){
        case (?member){
            // make the creator a member of the pool
            let newMember: Member = {
                name = member.name;
                stakedAmount = stake;
            };
            let _members = HashMap.HashMap<Principal,Member>(0,Principal.equal,Principal.hash);
            _members.put(caller,newMember);
            // create a new pool
            let newPool: Pool = {
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
        case (null){
            // Caller is not a member of the primary challenge
            return;
        };
    };


  
};

// public shared(msg) func transferToken(challengeId: Nat, sender: Principal, recipient: Principal, tokenName: Text, amount: Nat) : async Bool {
//     // Attempt to find the challenge directly among primary challenges
//     let maybePrimaryChallenge = Array.find(challenges, func(c) { c.id == challengeId });
//     switch (maybePrimaryChallenge) {
//         case (?primaryChallenge) {
//             // Primary challenge found, proceed with token transfer
//             return await transferWithinChallenge(primaryChallenge, sender, recipient, tokenName, amount);
//         };
//         case (null) {
//             // Primary challenge not found, search within child Pools
//             for (challenge in challenges) {
//                 let maybeChildChallenge = Array.find(challenge.children, func(c) { c.id == challengeId });
//                 switch (maybeChildChallenge) {
//                     case (?childChallenge) {
//                         // Child Pool found, proceed with token transfer
//                         return await transferWithinChallenge(childChallenge, sender, recipient, tokenName, amount);
//                     };
//                     case (null) {
//                         // Child Pool not found, continue searching
//                         continue;
//                     };
//                 };
//             };
//             // If no matching challenge or child Pool is found
//             return false;
//         };
//     };
// };

// Helper function to perform the token transfer within a given challenge
// private func transferWithinChallenge(challenge: Challenge, sender: Principal, recipient: Principal, tokenName: Text, amount: Nat) : Bool {
//     // Verify sender has enough tokens and perform the transfer
//     let senderIndex = Array.findInd(challenge.participants, func(u) { u.user == sender });
//     let recipientIndex = Array.findInd(challenge.participants, func(u) { u.user == recipient });
//     switch (senderIndex, recipientIndex) {
//         case (?sInd, ?rInd) {
//             // Both sender and recipient found
//             let senderTokens = challenge.participants[sInd].tokens;
//             let recipientTokens = challenge.participants[rInd].tokens;
//             let maybeTokenIndex = Array.findInd(senderTokens, func((t, _)) { t.name == tokenName });
//             switch (maybeTokenIndex) {
//                 case (?tokenIndex) {
//                     let (_, senderTokenAmount) = senderTokens[tokenIndex];
//                     if (senderTokenAmount < amount) {
//                         // Sender does not have enough tokens
//                         return false;
//                     };
//                     // Deduct from sender
//                     challenge.participants[sInd].tokens[tokenIndex] := (challenge.participants[sInd].tokens[tokenIndex].0, senderTokenAmount - amount);
//                     // Add to recipient
//                     let maybeRecipientTokenIndex = Array.findInd(recipientTokens, func((t, _)) { t.name == tokenName });
//                     switch (maybeRecipientTokenIndex) {
//                         case (null) {
//                             // Recipient does not have the token yet
//                             challenge.participants[rInd].tokens := Array.append(recipientTokens, ({name = tokenName, amount}));
//                         };
//                         case (?rTokenIndex) {
//                             let (_, recipientTokenAmount) = recipientTokens[rTokenIndex];
//                             challenge.participants[rInd].tokens[rTokenIndex] := (challenge.participants[rInd].tokens[rTokenIndex].0, recipientTokenAmount + amount);
//                         };
//                     };
//                     // Update the global state if necessary
//                     // This step depends on how your state management is set up
//                     return true;
//                 };
//                 case (null) {
//                     // Sender does not have the specified token
//                     return false;
//                 };
//             };
//         };
//         case _ {
//             // Either sender or recipient not found
//             return false;
//         };
//     };
// };

// public shared({caller}) func createPool(challengeId: Nat, creator: Principal, name: Text, stake: Nat, tokenName: Text): async Bool {
//   // Implementation to create a new pool within a challenge
// };

// // Function for members to join a pool
// public shared({caller}) func joinPool(challengeId: Nat, poolName: Text, member: Principal, stake: Nat): async Bool {
//   // Implementation for a member to join a pool and contribute $VALUE tokens
// };

 
};
