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

  let ledger : Principal = Principal.fromActor(ckbtc_ledger);
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

  public type DepositError = {
    #TransferFromError : ICRC.TransferError;
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
  // public shared ({ caller }) func send(to : Principal, amount : Nat, icrc1LedgerPrincipal : Text) : async Result.Result<Nat, Text> {

  // public shared ({ caller }) func transfer(args : TransferArgs) : async Result.Result<ckbtc_ledger.BlockIndex, Text> {


  public shared ({ caller }) func send(amount : Nat, Name : Text) : async Result.Result<Nat, Text> { 
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
        owner = Principal.fromActor(multiPay); 
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
          case _ { "Unknown transfer error" };
        };
        return #err(errorMessage);
      };
    };

  };


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
        let result_Trans =  await ckbtc_ledger.icrc2_approve(args);


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

  public shared ({ caller = _ }) func transferFrom(amount : Nat, from : Principal, to : Principal) : async Result.Result<Nat,Text> {
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
          case _ { "Unknown transfer error" };
        };
        return #err(errorMessage);
      };
    };
     };


  public shared ({ caller }) func depositAndTransfer(to: Principal, amount: Nat, icrc1LedgerPrincipal: Principal) : async Result.Result<Nat, Text> {
    // Here, we assume the "deposit" is an incoming transfer to this canister's controlled account.
    // This would be a transfer initiated externally, so the next step is to transfer the amount to the specified `to` Principal.

    // Perform the transfer using the ledger canister
    let transferResult = await ckbtc_ledger.icrc1_transfer({
      to = {
        owner = to;
        subaccount = null;
      };
      amount = amount;
      from_subaccount = null; // Assuming this transfer is from the canister's main account.
      created_at_time = null;
      fee = ?10; // Assuming a fixed fee for simplicity. Consider dynamic fee handling.
      memo = null;
    });

    // Handle the transfer result similarly to your existing send function
    switch (transferResult) {
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





  public shared (messageObject) func whoami() : async Principal {
    let { caller } = messageObject;
    caller;
  };
};
