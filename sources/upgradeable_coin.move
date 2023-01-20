module upgradeable_coin::coin {
    struct Coin {}

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
    }
}