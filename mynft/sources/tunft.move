module mynft::tunft{
    use std::string::utf8;
    use std::ascii::{Self, String};
    use sui::object::{Self, UID};
    use sui::display;
    use sui::tx_context::{Self, TxContext};
    use sui::package;
    use sui::transfer;

    struct TUNFT has drop {}
    struct NftTu has key{
        id: UID,
        name: String,
        img_url: String
    }

    fun init(otw:TUNFT, ctx: &mut TxContext){
        let publisher = package::claim(otw, ctx);
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
        ];
        let values = vector[
            utf8(b"{name}"),
            utf8(b"https://github.com/daisyYoY?tab=repositories"),
            utf8(b"{img_url}"),
            utf8(b"Profile NFT for sui startrek program"),
        ];

        let display = display::new_with_fields<NftTu>(&publisher, keys, values, ctx);
        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));

        let nft = NftTu{
            id: object::new(ctx),
            name: ascii::string(b"daisyYoY"),
            img_url: ascii::string(b"ipfs://QmdDTor6dWzknFJPJuhJgrUYqd56WkFXYAxyxpEY7kUrEb"),
        };

        transfer::transfer(nft, tx_context::sender(ctx));
    }

    entry fun create(name: vector<u8>, img_url:vector<u8>, ctx: &mut TxContext){
        let nft = NftTu{
            id: object::new(ctx),
            name: ascii::string(name),
            img_url: ascii::string(img_url),
        };

        transfer::transfer(nft, tx_context::sender(ctx));
    }
}
