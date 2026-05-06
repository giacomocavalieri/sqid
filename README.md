# sqid

[![Package Version](https://img.shields.io/hexpm/v/sqid)](https://hex.pm/packages/sqid)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sqid/)

Sqids (pronounced "squids") are short unique identifiers generated from numbers.
These IDs are URL-safe, can encode several numbers, and can be made to not
contain profanity words.

The main use of Sqids is purely visual. This is not an encryption library, and
Sqids should not carry secrets: anyone who can guess the encoding alphabet will
have access to the numbers that generated a Sqid.
You can read more about sqid's use cases [on their website!](https://sqids.org)

This is how you create a squid:

```sh
gleam add sqid@1
```

```gleam
import sqid

pub fn main() -> Nil {
  // Start by defining what alphabet you want to use to generate sqids
  let assert Ok(alphabet) = sqid.alphabet("abcdefghijklmnopqrstuvwxyz")
  // You can also set a minimum length for generated Sqids
  let sqid = sqid.new(alphabet) |> sqid.set_minimum_length(8)
  // Turn any sequence of numbers into a Sqid!
  assert Ok("voqcetma") == sqid.encode(sqid, [11])
}
```
