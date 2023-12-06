module mynft::game{
    use std::vector as vec;
    use std::bcs;
    use std::hash;

    use sui::event::emit;
    use sui::transfer;
    use sui::sui::SUI;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    const E_INVALID_RND_LENGTH: u64 = 1;
    const ERR_NOT_CORRECT_GESTURE: u64 = 2;

    const ROCK: u8 = 0;
    const PAPER: u8 = 1;
    const SCISSORS: u8 = 2;

    // result
    /// 0: draw, 1: player win, 2: computer win
    struct Result has copy, drop{
        status: u8
    }

    struct Reg has key{
        id: UID,
        round: u64
    }

    fun init(ctx: &mut TxContext){
        // reg
        let reg = Reg{
            id: object::new(ctx),
            round: 0
        };
        transfer::share_object(reg);
    }

    entry public fun play(reg: &Reg, guess: u8, ctx: &mut TxContext){
        if(guess > 2) abort ERR_NOT_CORRECT_GESTURE;

        let uid = object::new(ctx);
        let rand = object::uid_to_bytes(&uid);
        object::delete(uid);
        let rand_1 = bcs::to_bytes(&reg.round);
        vec::append(&mut rand, rand_1);
        let hash = hash::sha2_256(rand);
        let comp_guess = (safe_selection(3, &hash) as u8);

        // logic
        if(guess == comp_guess){
            emit(Result{status:0})
        }else{
            let player_win = if((guess == ROCK && comp_guess == SCISSORS) || (guess == SCISSORS && comp_guess == PAPER) || (guess == PAPER && comp_guess == ROCK)) true else false;

            if(player_win) emit(Result{status:1}) else emit(Result{status:2});
        };
    }

    public fun safe_selection(n: u64, rnd: &vector<u8>): u64 {
        assert!(vec::length(rnd) >= 16, E_INVALID_RND_LENGTH);
        let m: u128 = 0;
        let i = 0;
        while (i < 16) {
            m = m << 8;
            let curr_byte = *vec::borrow(rnd, i);
            m = m + (curr_byte as u128);
            i = i + 1;
        };
        let n_128 = (n as u128);
        let module_128  = m % n_128;
        let res = (module_128 as u64);
        res
    }
}