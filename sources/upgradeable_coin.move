module upgradeable_coin::coin {
    use std::signer;
    
    const ENOT_ZERO_ADDRESS: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const ENOT_PROPOSED_OWNER: u64 = 2;

    struct Coin {}

    struct State has key {
        owner: address,
        proposed_owner: address
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
            proposed_owner: @0x0
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

    public fun owner(): address acquires State {
        borrow_global<State>(@upgradeable_coin).owner
    }

    public fun proposed_owner(): address acquires State {
        borrow_global<State>(@upgradeable_coin).proposed_owner
    }

    fun only_owner(account: address) acquires State {
        assert!(account == borrow_global<State>(@upgradeable_coin).owner, ENOT_OWNER);
    }

    fun only_proposed_owner(account: address) acquires State {
        assert!(account == borrow_global<State>(@upgradeable_coin).proposed_owner, ENOT_PROPOSED_OWNER);
    }
}