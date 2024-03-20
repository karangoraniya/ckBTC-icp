import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Error "mo:base/Error";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import P "mo:base/Prelude";
import TrieMap "mo:base/TrieMap";
import Time "mo:base/Time";

import ckbtc_ledger "canister:ckbtc_ledger";
import ICRC "./ICRC"

actor multiPay {

  // let ledger : Principal = Principal.fromActor(ckbtc_ledger);
  public type Subaccount = Blob;

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };
    
  public type DepositArgs = {
    spender_subaccount : ?Blob;
    token: Principal;
    from: ICRC.Account;
    amount: Nat;
    fee: ?Nat;
    memo: ?Blob;
    created_time : ?Nat64;
  };

  type DepositArgss = {
    amount : Nat;
    fromAccount : Account;
  };

   type Account = {
    owner : Principal;
    subaccount : ?[Nat8];
  };



  // example of how to make inter canister calls to the ledger in motoko
  public shared ({ caller }) func send(to : Principal, amount : Nat, icrc1LedgerPrincipal : Text) : async Result.Result<Nat, Text> {

  // public shared ({ caller }) func transfer(args : TransferArgs) : async Result.Result<ckbtc_ledger.BlockIndex, Text> {


  // public shared ({ caller }) func send(amount : Nat, Name : Text) : async Result.Result<Nat, Text> { 
    let balanceArg = {
      owner = caller;
      // owner = caller;
      subaccount = null; // Explicitly setting subaccount as null if not used
    };

    let currentBalance = await ckbtc_ledger.icrc1_balance_of(balanceArg);

    // let balance = await ckbtc_ledger.icrc1_balance_of(
    //   toAccount({ caller; canister = Principal.fromActor(FortuneCookie) })
    // );

    let transferResult = await ckbtc_ledger.icrc1_transfer({
      to = { 
        owner = to; 
        // owner = Principal.fromActor(multiPay); 
        subaccount = null; };
      // to = {
      //   owner = ;
      //   // owner = to;
      //   subaccount = null;
      // };
      amount = amount;
      from_subaccount = null;
      // from_subaccount = ?caller;
      created_at_time = null;
      fee = ?10;
      memo = null;
    });

    switch (transferResult) {
      case (#Ok(blockIndex)) {
        return #ok(blockIndex);
      };
      case (#Err(error)) {
        let errorMessage = switch (error) {
          case (#BadFee(_)) { "Bad fee" };
          case (#InsufficientFunds(_)) { "Insufficient funds" };
          // Add cases for other possible TransferError variants
          // case _ { "Unknown transfer error" };
          case (#GenericError(_)) { "Generic error" };
          case (#TemporarilyUnavailable) { "Temporarily unavailable" };
          case (#BadBurn(_)) { "Bad burn" };
          case (#Duplicate(_)) { "Duplicate" };
          case (#CreatedInFuture(_)) { "Created in future" };
          case (#TooOld) { "Too old" };
        };
        return #err(errorMessage);
      };
    };

  };


let ledger_actor = actor("mxzaz-hqaaa-aaaar-qaada-cai") : actor {
         icrc2_approve : shared (args : {
             amount : Nat;
             created_at_time : ?Int;
             expected_allowance : ?Nat;
             expires_at : ?Int;
             fee: ?Nat;
             from_subaccount : ?Blob;
             memo: ?Blob;
             spender : { owner : Principal; subaccount : ?Blob };
         }) -> async Result.Result<Nat,Text>;
     };
 
//  icrc1_balance_of: (record {owner:principal; subaccount:opt vec nat8}) → (nat) query


  public shared ({ caller = owner }) func approve(amount : Nat) : async Result.Result<Nat,Text> {
         let args = {
             amount;
             created_at_time = null;
             expected_allowance = null;
             expires_at = null;
             fee = null;
             from_subaccount = null;
             memo = null;
             spender = { owner; subaccount = null };
         };

    //       let ledger_actor : actor {
    //     icrc2_approve : shared (args : {
    //         amount : Nat;
    //         created_at_time : ?Int;
    //         expected_allowance : ?Nat;
    //         expires_at : ?Int;
    //         fee : ?Nat;
    //         from_subaccount : ?Blob;
    //         memo : ?Blob;
    //         spender : { owner : Principal; subaccount : ?Blob };
    //     }) -> async Result.Result<Nat,Text>;
    // } = actor "mxzaz-hqaaa-aaaar-qaada-cai"; 

    let result_Trans = await ledger_actor.icrc2_approve(args);


        // let result_Trans =  await ckbtc_ledger.icrc2_approve(args);


    switch (result_Trans) {
      case (#Ok(blockIndex)) {
        return #ok(blockIndex);
      };
      case (#Err(error)) {
        let errorMessage = switch (error) {
          case (#BadFee(_)) { "Bad fee" };
          case (#InsufficientFunds(_)) { "Insufficient funds" };
          // Add cases for other possible TransferError variants
          case _ { "Unknown transfer error" };
        };
        return #err(errorMessage);
      };
    };
     };

  public shared ({ caller  }) func transfer_old(amount : Nat, from : Principal, to : Principal) : async Result.Result<Nat,Text> {
         assert(from == caller);
         let args = {
             to = { owner = to; subaccount = null };
             fee = null;
             spender_subaccount = null;
             from = { owner = from; subaccount = null };
             memo = null;
             created_at_time = null;
             amount =amount;
         };
         let transf_Result = await ckbtc_ledger.icrc2_transfer_from(args);
         switch (transf_Result) {
      case (#Ok(blockIndex)) {
        return #ok(blockIndex);
      };
      case (#Err(error)) {
        let errorMessage = switch (error) {
          case (#BadFee(_)) { "Bad fee" };
          case (#InsufficientFunds(_)) { "Insufficient funds" };
          // Add cases for other possible TransferError variants
           case (#GenericError(_)) { "Generic error" };
          case (#TemporarilyUnavailable) { "Temporarily unavailable" };
          case (#BadBurn(_)) { "Bad burn" };
          case (#Duplicate(_)) { "Duplicate" };
          case (#CreatedInFuture(_)) { "Created in future" };
          case (#TooOld) { "Too old" };
          case _ { "Unknown transfer error" };
        };
        return #err(errorMessage);
      };
    };
     };



    public shared ({ caller}) func transfer(amount : Nat, to : Principal) : async Result.Result<Nat, Text> {
         let args = {
             to = { owner = to; subaccount = null };
             fee = null;
             spender_subaccount = null;
             from = { owner = caller; subaccount = null };
             memo = null;
             created_at_time = null;
             amount = amount;
         };
         let transf_Result = await ckbtc_ledger.icrc2_transfer_from(args);
         switch (transf_Result) {
             case (#Ok(blockIndex)) {
                 return #ok(blockIndex);
             };
             case (#Err(error)) {
                 let errorMessage = switch (error) {
                     case (#BadFee(_)) { "Bad fee" };
                     case (#InsufficientFunds(_)) { "Insufficient funds" };
                     case (#GenericError(_)) { "Generic error" };
                     case (#TemporarilyUnavailable) { "Temporarily unavailable" };
                     case (#BadBurn(_)) { "Bad burn" };
                     case (#Duplicate(_)) { "Duplicate" };
                     case (#CreatedInFuture(_)) { "Created in future" };
                     case (#TooOld) { "Too old" };
                     case _ { "Unknown transfer error" };
                 };
                 return #err(errorMessage);
             };
         };
    };
 
  

  public shared (messageObject) func whoami() : async Principal {
    let { caller } = messageObject;
    caller;
  };
};



