import Time "mo:base/Time";
import Types "./types";
import icrcTypes "./icrc";
actor Freem {

type Token = Types.Token;
type UserToken = Types.UserToken;
type Incentive = Types.Incentive;
type Challenge = Types.Challenge;
type Pool = Types.Pool;

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

// Function to create a new challenge
var challengeId: Nat = 0;
public shared({caller}) func createChallenge(challenge: Challenge): Bool {
  
    //  Validate Input
    assert(challenge.name != "" and challenge.description != "", "Challenge details are invalid.");
    assert(challengeDetails.stakeAmount >= 1.0, "Minimum stake amount is not met.");

    // create a predefined list of incentives
    let incentives: [Incentive] = [
        {id = 1; description = "Complete 10 pushups"; rewardTokenName = "$Fitness"; rewardAmount = 30},
        {id = 2; description = "Complete 10 situps"; rewardTokenName = "$Fitness"; rewardAmount = 10},
    ];
    

    //add caller to the participants list
    let userToken: UserToken = {user = caller; tokens = [(Token{challengeId = challengeId, name = "$Fitness"}, challenge.stakeAmount)]};

 
    // create a new challenge
    let newChallenge: Challenge = {
        id = challengeId;
        name = challenge.name;
        description = challenge.description;
        stakeAmount = challenge.stakeAmount;
        startDate = Time.now();
        endDate = Time.add(Time.now(), 30, "day");
        participants = [];
        stakeAmount = challenge.stakeAmount;
        incentives = incentives;
    };

    
          
};

// Function to earn $VALUE tokens
public func earnValueTokens(member: Principal, amount: Nat): Bool {
  // Implementation to credit $VALUE tokens to a member
};

// Function to transfer $VALUE tokens between members
public func transferValueTokens(from: Principal, to: Principal, amount: Nat): Bool {
   
    


};

import Principal "mo:base/Principal";
import Array "mo:base/Array";

// Assuming a global state for challenges (for demonstration)
var challenges: [Challenge] = [];

public shared(msg) func transferToken(challengeId: Nat, sender: Principal, recipient: Principal, tokenName: Text, amount: Nat) : async Bool {
    // Attempt to find the challenge directly among primary challenges
    let maybePrimaryChallenge = Array.find(challenges, func(c) { c.id == challengeId });
    switch (maybePrimaryChallenge) {
        case (?primaryChallenge) {
            // Primary challenge found, proceed with token transfer
            return await transferWithinChallenge(primaryChallenge, sender, recipient, tokenName, amount);
        };
        case (null) {
            // Primary challenge not found, search within child Pools
            for (challenge in challenges) {
                let maybeChildChallenge = Array.find(challenge.children, func(c) { c.id == challengeId });
                switch (maybeChildChallenge) {
                    case (?childChallenge) {
                        // Child Pool found, proceed with token transfer
                        return await transferWithinChallenge(childChallenge, sender, recipient, tokenName, amount);
                    };
                    case (null) {
                        // Child Pool not found, continue searching
                        continue;
                    };
                };
            };
            // If no matching challenge or child Pool is found
            return false;
        };
    };
}

// Helper function to perform the token transfer within a given challenge
private func transferWithinChallenge(challenge: Challenge, sender: Principal, recipient: Principal, tokenName: Text, amount: Nat) : Bool {
    // Verify sender has enough tokens and perform the transfer
    let senderIndex = Array.findInd(challenge.participants, func(u) { u.user == sender });
    let recipientIndex = Array.findInd(challenge.participants, func(u) { u.user == recipient });
    switch (senderIndex, recipientIndex) {
        case (?sInd, ?rInd) {
            // Both sender and recipient found
            let senderTokens = challenge.participants[sInd].tokens;
            let recipientTokens = challenge.participants[rInd].tokens;
            let maybeTokenIndex = Array.findInd(senderTokens, func((t, _)) { t.name == tokenName });
            switch (maybeTokenIndex) {
                case (?tokenIndex) {
                    let (_, senderTokenAmount) = senderTokens[tokenIndex];
                    if (senderTokenAmount < amount) {
                        // Sender does not have enough tokens
                        return false;
                    };
                    // Deduct from sender
                    challenge.participants[sInd].tokens[tokenIndex] := (challenge.participants[sInd].tokens[tokenIndex].0, senderTokenAmount - amount);
                    // Add to recipient
                    let maybeRecipientTokenIndex = Array.findInd(recipientTokens, func((t, _)) { t.name == tokenName });
                    switch (maybeRecipientTokenIndex) {
                        case (null) {
                            // Recipient does not have the token yet
                            challenge.participants[rInd].tokens := Array.append(recipientTokens, ({name = tokenName, amount}));
                        };
                        case (?rTokenIndex) {
                            let (_, recipientTokenAmount) = recipientTokens[rTokenIndex];
                            challenge.participants[rInd].tokens[rTokenIndex] := (challenge.participants[rInd].tokens[rTokenIndex].0, recipientTokenAmount + amount);
                        };
                    };
                    // Update the global state if necessary
                    // This step depends on how your state management is set up
                    return true;
                };
                case (null) {
                    // Sender does not have the specified token
                    return false;
                };
            };
        };
        case _ {
            // Either sender or recipient not found
            return false;
        };
    };
}

// Function to create a pool with $VALUE tokens
var nextPoolId: Nat = 0;
public func createPool(challengeId: Nat, creator: Principal, name: Text, stake: Nat, tokenName: Text): Bool {
  // Implementation to create a new pool within a challenge
};

// Function for members to join a pool
public func joinPool(challengeId: Nat, poolName: Text, member: Principal, stake: Nat): Bool {
  // Implementation for a member to join a pool and contribute $VALUE tokens
};

 
};
