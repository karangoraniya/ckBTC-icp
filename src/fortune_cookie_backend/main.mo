import Result "mo:base/Result";
import Int "mo:base/Int";
import Time "mo:base/Time";
import CkBtcLedger "canister:ckbtc_ledger";
import Types "./types";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import { toAccount; toSubaccount; createInvoice } "./utils";
import Nat "mo:base/Nat";

actor FortuneCookie {

  // let cookies = [
  //   "A journey of a thousand miles begins with a single step.",
  //   "Your greatest fortune is the friends you keep.",
  //   "Good things come to those who wait.",
  //   "The best way to predict the future is to create it.",
  //   "Opportunity knocks on your door every day. Be ready to answer.",
  //   "Success is the sum of small efforts repeated day in and day out.",
  //   "Believe in yourself, and others will too.",
  //   "A smile is the universal language of kindness.",
  //   "Your dreams are within reach. Pursue them with passion.",
  //   "Kindness is a gift that keeps on giving.",
  //   "Patience is the key to unlocking life's greatest treasures.",
  //   "Fortune favors the bold.",
  //   "Success is not final, failure is not fatal: It is the courage to continue that counts.",
  //   "The greatest risk is not taking any risks at all.",
  //   "Your positive attitude will lead to positive outcomes.",
  //   "In every ending, there is a new beginning.",
  //   "Happiness is not a destination, but a way of life.",
  //   "Success is not measured by wealth, but by the impact you make on others.",
  //   "Embrace change, for it leads to growth.",
  //   "The best lessons are learned from mistakes.",
  //   "Your creative ideas will lead to great achievements.",
  //   "The secret to happiness is to count your blessings.",
  //   "Love and laughter are the keys to a joyful heart.",
  //   "Success comes to those who work for it.",
  //   "You have the power to make a difference in the world.",
  //   "Cherish the present moment, for it is a gift.",
  //   "Persistence and determination will bring you closer to your goals.",
  //   "A kind word can change someone's entire day.",
  //   "The only limit is the one you set for yourself.",
  //   "Take the road less traveled, and you will discover new horizons.",
  //   "Your greatest strength lies within you.",
  //   "Luck is what happens when preparation meets opportunity.",
  //   "Every setback is a setup for a comeback.",
  //   "A grateful heart attracts abundance.",
  //   "The best is yet to come.",
  //   "The harder you work, the luckier you get.",
  //   "Life is a beautiful journey. Enjoy every step.",
  //   "Your passion will lead you to success.",
  //   "Every problem has a solution. Keep a positive mindset.",
  //   "Wisdom is knowing what to do; virtue is doing it.",
  //   "You are capable of achieving great things.",
  //   "A kind gesture can change someone's entire day.",
  //   "Great things take time. Be patient.",
  //   "Believe in yourself, and others will believe in you.",
  //   "Your generosity will be rewarded tenfold.",
  //   "Keep your face always toward the sunshine, and shadows will fall behind you.",
  //   "Success is not just about reaching the destination, but enjoying the journey.",
  //   "An open mind is an opportunity magnet.",
  //   "The world is full of endless possibilities. Embrace them.",
  //   "Your potential is limitless. Believe in yourself and aim high.",
  // ];

  public shared ({ caller }) func getCookie() : async Result.Result<Text, Text> {

    // check ckBTC balance of the callers dedicated account
    let balance = await CkBtcLedger.icrc1_balance_of(
      toAccount({ caller; canister = Principal.fromActor(FortuneCookie) })
    );

    if (balance < 100) {
      return #err("Not enough funds available in the Account. Make sure you send at least 100 ckSats.");
    };

    try {
      // if enough funds were sent, move them to the canisters default account
      let transferResult = await CkBtcLedger.icrc1_transfer(
        {
          amount = balance - 10;
          from_subaccount = ?toSubaccount(caller);
          created_at_time = null;
          // record {
          //   to = record {
          //     owner = principal "bd3sg-teaaa-aaaaa-qaaba-cai";
          //     subaccount = opt blob "\00\00\1d\0e\c4\9a^!\b9\e3\9e\c4\fb4f\84\dcR\dbx\d1\06s\8d\1a:/\a6\8d:\81\02";
          //   };
          //   amount = 100 : nat;
          // };
          fee = ?10;
          memo = null;
          to = {
            owner = Principal.fromActor(FortuneCookie);
            subaccount = null;
          };
        }
      );

      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Couldn't transfer funds to default account:\n" # debug_show (transferError));
        };
        case (_) {
          return #err("Nothing");
        };
      };
    } catch (error : Error) {
      return #err("Reject message: " # Error.message(error));
    };

  };

  public shared ({ caller }) func getInvoice() : async Types.Invoice {
    createInvoice(toAccount({ caller; canister = Principal.fromActor(FortuneCookie) }), 100);
  };

  public func createTx(account : Types.Account, amount : Nat) : async Types.Invoice {
    return {
      to = account;
      amount = amount;
    };
  };

  public shared ({ caller }) func transferCkBTC(to : Principal, amount : Nat, icrc1LedgerPrincipal:Text) : async Result.Result<Nat, Text> {

    let Management = actor (icrc1LedgerPrincipal) : actor {
      raw_rand : () -> async Blob;
    };



    let balance = await CkBtcLedger.icrc1_balance_of(
      toAccount({ caller; canister = Principal.fromActor(FortuneCookie) })
    );

    try {

      let transferResult = await CkBtcLedger.icrc1_transfer({
        from_subaccount = ?toSubaccount(caller); // Assuming transfer from the main account of the caller
        to = {
          owner = to; // Destination principal
          subaccount = null; // Assuming transfer to the main account of the recipient
        };
        amount = amount; // Amount to transfer
        fee = ?10; // Assuming a fixed fee, adjust as necessary
        memo = null; // Optional, provide if needed
        created_at_time = null; // Optional, provide if needed
      });

      switch (transferResult) {
        case (#ok(txId)) {
          #ok(txId) // Return the transaction ID on success
        };
        case (#err(errMsg)) {
          #err(errMsg) // Return the error message on failure
        };
      };

    } catch (error : Error) {
      return #err("Payment Failed:");
    };
  };
};
