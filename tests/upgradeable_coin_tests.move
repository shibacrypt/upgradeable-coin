#[test_only]
module upgradeable_coin::coin_test {
    use std::signer;
    use std::string;
    use std::option;
    
    use aptos_framework::coin;
    use aptos_framework::managed_coin;
    
    use upgradeable_coin::coin::Coin;
    
    #[test(account = @upgradeable_coin, owner = @owner)]
    fun test_initialize(account: signer, owner: signer) {
        let owner_addr = signer::address_of(&owner);
        upgradeable_coin::coin::initialize(&account);

        assert!(coin::is_coin_initialized<Coin>(), 0);
        assert!(coin::name<Coin>() == string::utf8(b"Upgradeable Coin"), 0);
        assert!(coin::symbol<Coin>() == string::utf8(b"COIN"), 0);
        assert!(coin::decimals<Coin>() == 8, 0);
        assert!(option::is_some(&coin::supply<Coin>()), 0);
        assert!(upgradeable_coin::coin::owner() == owner_addr, 0);
    }

    #[test(account = @upgradeable_coin)]
    #[expected_failure(abort_code = 0x80002, location = coin)]
    fun fail_test_initialize_twice(account: signer) {
        upgradeable_coin::coin::initialize(&account);
        upgradeable_coin::coin::initialize(&account);
    }

    #[test(account = @upgradeable_coin, user = @0xa11ce)]
    fun test_mint(account: signer, user: signer) {
        let user_addr = signer::address_of(&user);
        aptos_framework::account::create_account_for_test(user_addr);

        upgradeable_coin::coin::initialize(&account);
        
        managed_coin::register<Coin>(&user);
        managed_coin::mint<Coin>(&account, user_addr, 100);
        assert!(coin::balance<Coin>(user_addr) == 100, 0);
        assert!(option::extract(&mut coin::supply<Coin>()) == 100, 0);
    }

    #[test(account = @upgradeable_coin, user = @0xa11ce)]
    #[expected_failure(abort_code = 0x60001, location = managed_coin)]
    fun fail_mint_using_user(account: signer, user: signer) {
        let user_addr = signer::address_of(&user);
        aptos_framework::account::create_account_for_test(user_addr);

        upgradeable_coin::coin::initialize(&account);
        
        managed_coin::mint<Coin>(&user, user_addr, 100);
    }

    #[test(account = @upgradeable_coin)]
    fun test_burn_self(account: signer) {
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);

        upgradeable_coin::coin::initialize(&account);
        
        managed_coin::register<Coin>(&account);
        managed_coin::mint<Coin>(&account, addr, 100);
        managed_coin::burn<Coin>(&account, 10);
        assert!(coin::balance<Coin>(addr) == 90, 0);
        assert!(option::extract(&mut coin::supply<Coin>()) == 90, 0);
    }

    #[test(account = @upgradeable_coin, user = @0xa11ce)]
    #[expected_failure(abort_code = 0x60001, location = managed_coin)]
    fun fail_burn_using_user(account: signer, user: signer) {
        let user_addr = signer::address_of(&user);
        aptos_framework::account::create_account_for_test(user_addr);

        upgradeable_coin::coin::initialize(&account);
        
        managed_coin::register<Coin>(&user);
        managed_coin::mint<Coin>(&account, user_addr, 100);
        managed_coin::burn<Coin>(&user, 10);
    }
}