module upgradeable_coin::coin {
    use std::signer;
    
    const ENOT_ZERO_ADDRESS: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const ENOT_PROPOSED_OWNER: u64 = 2;
    const ENOT_PAUSED: u64 = 3;

    struct Coin {}

    struct State has key {
        owner: address,
        proposed_owner: address,
        paused: bool
    }
    
    fun init_module(account: &signer) {
        initialize(account);
    }

    public fun initialize(account: &signer) {
        aptos_framework::managed_coin::initialize<Coin>(
            account,
            b"Upgradeable Coin",
            b"COIN",
            8,
            true,
        );

        move_to(account, State {
            owner: @owner,
            proposed_owner: @0x0,
            paused: false
        });
    }

    public fun push_ownership(account: &signer, new_owner: address) acquires State {
        only_owner(signer::address_of(account));
        assert!(new_owner != @0x0, ENOT_ZERO_ADDRESS);
        borrow_global_mut<State>(@upgradeable_coin).proposed_owner = new_owner;
    }

    public fun pull_ownership(account: &signer) acquires State {
        only_proposed_owner(signer::address_of(account));
        borrow_global_mut<State>(@upgradeable_coin).owner = borrow_global<State>(@upgradeable_coin).proposed_owner;
        borrow_global_mut<State>(@upgradeable_coin).proposed_owner = @0x0;
    }

    public fun pause(account: &signer) acquires State {
        only_owner(signer::address_of(account));
        borrow_global_mut<State>(@upgradeable_coin).paused = true;
    }

    public fun unpause(account: &signer) acquires State {
        only_owner(signer::address_of(account));
        borrow_global_mut<State>(@upgradeable_coin).paused = false;
    }

    public fun owner(): address acquires State {
        borrow_global<State>(@upgradeable_coin).owner
    }

    public fun proposed_owner(): address acquires State {
        borrow_global<State>(@upgradeable_coin).proposed_owner
    }

    public fun paused(): bool acquires State {
        borrow_global<State>(@upgradeable_coin).paused
    }

    fun only_owner(account: address) acquires State {
        assert!(account == borrow_global<State>(@upgradeable_coin).owner, ENOT_OWNER);
    }

    fun only_proposed_owner(account: address) acquires State {
        assert!(account == borrow_global<State>(@upgradeable_coin).proposed_owner, ENOT_PROPOSED_OWNER);
    }

    fun when_paused() acquires State {
        assert!(borrow_global<State>(@upgradeable_coin).paused, ENOT_PAUSED);
    }
}