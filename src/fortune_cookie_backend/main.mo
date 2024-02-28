import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Error "mo:base/Error";
import ckbtc_ledger "canister:ckbtc_ledger";


actor multiPay {

  public type Subaccount = Blob;

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };
    


  // public func toAccount({ caller : Principal; canister : Principal }) : Types.Account {
  //   {
  //     owner = canister;
  //     subaccount = ?toSubaccount(caller);
  //   };
  // };

  // example of how to make inter canister calls to the ledger in motoko
  public shared ({ caller }) func send(to : Principal, amount : Nat, icrc1LedgerPrincipal : Text) : async Result.Result<Nat, Text> {

    let balanceArg = {
      owner = caller;
      subaccount = null; // Explicitly setting subaccount as null if not used
    };

    let currentBalance = await ckbtc_ledger.icrc1_balance_of(balanceArg);

    // let balance = await ckbtc_ledger.icrc1_balance_of(
    //   toAccount({ caller; canister = Principal.fromActor(FortuneCookie) })
    // );

    let transferResult = await ckbtc_ledger.icrc1_transfer({
      amount = amount;
      from_subaccount = null;
      // from_subaccount = ?caller;
      created_at_time = null;
      fee = ?10;
      memo = null;
      to = {
        owner = to;
        subaccount = null;
      };
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

  public shared (messageObject) func whoami() : async Principal {
    let { caller } = messageObject;
    caller;
  };

};
