import gleam/int
import gleam/list
import gleeunit
import sqid

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn alphabet_must_be_at_least_3_test() {
  assert Error(Nil) == sqid.alphabet("ab")
}

pub fn alphabet_must_not_have_duplicates_test() {
  assert Error(Nil) == sqid.alphabet("aabcdefg")
}

pub fn alphabet_must_not_have_multi_byte_characters_test() {
  assert Error(Nil) == sqid.alphabet("ë1092")
}

pub fn alphabet_must_not_have_multi_byte_characters_2_test() {
  assert Error(Nil) == sqid.alphabet("102èasd")
}

const test_alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

fn encode(numbers: List(Int)) -> Result(String, Nil) {
  let assert Ok(alphabet) = sqid.alphabet(test_alphabet)
  let options = sqid.new(alphabet)
  sqid.encode(options, numbers)
}

fn encode_with(
  numbers: List(Int),
  minimum_length minimum_length: Int,
) -> Result(String, Nil) {
  let assert Ok(alphabet) = sqid.alphabet(test_alphabet)
  let options = sqid.new(alphabet) |> sqid.set_minimum_length(minimum_length)
  sqid.encode(options, numbers)
}

fn decode(sqid: String) -> Result(List(Int), Nil) {
  let assert Ok(alphabet) = sqid.alphabet(test_alphabet)
  let options = sqid.new(alphabet)
  sqid.decode(options, sqid)
}

fn decode_with(
  sqid: String,
  minimum_length minimum_length: Int,
) -> Result(List(Int), Nil) {
  let assert Ok(alphabet) = sqid.alphabet(test_alphabet)
  let options = sqid.new(alphabet) |> sqid.set_minimum_length(minimum_length)
  sqid.decode(options, sqid)
}

pub fn encode_empty_test() {
  assert Ok("") == encode([])
}

pub fn decode_empty_test() {
  assert Ok([]) == decode("")
}

pub fn encode_0_test() {
  assert Ok("bM") == encode([0])
}

pub fn decode_0_test() {
  assert Ok([0]) == decode("bM")
}

pub fn encode_1_test() {
  assert Ok("Uk") == encode([1])
}

pub fn decode_1_test() {
  assert Ok([1]) == decode("Uk")
}

pub fn encode_2_test() {
  assert Ok("gb") == encode([2])
}

pub fn decode_2_test() {
  assert Ok([2]) == decode("gb")
}

pub fn encode_3_test() {
  assert Ok("Ef") == encode([3])
}

pub fn decode_3_test() {
  assert Ok([3]) == decode("Ef")
}

pub fn encode_4_test() {
  assert Ok("Vq") == encode([4])
}

pub fn decode_4_test() {
  assert Ok([4]) == decode("Vq")
}

pub fn encode_5_test() {
  assert Ok("uw") == encode([5])
}

pub fn decode_5_test() {
  assert Ok([5]) == decode("uw")
}

pub fn encode_6_test() {
  assert Ok("OI") == encode([6])
}

pub fn decode_6_test() {
  assert Ok([6]) == decode("OI")
}

pub fn encode_7_test() {
  assert Ok("AX") == encode([7])
}

pub fn decode_7_test() {
  assert Ok([7]) == decode("AX")
}

pub fn encode_8_test() {
  assert Ok("p6") == encode([8])
}

pub fn decode_8_test() {
  assert Ok([8]) == decode("p6")
}

pub fn encode_9_test() {
  assert Ok("nJ") == encode([9])
}

pub fn decode_9_test() {
  assert Ok([9]) == decode("nJ")
}

pub fn encode_00_test() {
  assert Ok("SvIz") == encode([0, 0])
}

pub fn decode_00_test() {
  assert Ok([0, 0]) == decode("SvIz")
}

pub fn encode_01_test() {
  assert Ok("n3qa") == encode([0, 1])
}

pub fn decode_01_test() {
  assert Ok([0, 1]) == decode("n3qa")
}

pub fn encode_02_test() {
  assert Ok("tryF") == encode([0, 2])
}

pub fn decode_02_test() {
  assert Ok([0, 2]) == decode("tryF")
}

pub fn encode_03_test() {
  assert Ok("eg6q") == encode([0, 3])
}

pub fn decode_03_test() {
  assert Ok([0, 3]) == decode("eg6q")
}

pub fn encode_04_test() {
  assert Ok("rSCF") == encode([0, 4])
}

pub fn decode_04_test() {
  assert Ok([0, 4]) == decode("rSCF")
}

pub fn encode_05_test() {
  assert Ok("sR8x") == encode([0, 5])
}

pub fn decode_05_test() {
  assert Ok([0, 5]) == decode("sR8x")
}

pub fn encode_06_test() {
  assert Ok("uY2M") == encode([0, 6])
}

pub fn decode_06_test() {
  assert Ok([0, 6]) == decode("uY2M")
}

pub fn encode_07_test() {
  assert Ok("74dI") == encode([0, 7])
}

pub fn decode_07_test() {
  assert Ok([0, 7]) == decode("74dI")
}

pub fn encode_08_test() {
  assert Ok("30WX") == encode([0, 8])
}

pub fn decode_08_test() {
  assert Ok([0, 8]) == decode("30WX")
}

pub fn encode_09_test() {
  assert Ok("moxr") == encode([0, 9])
}

pub fn decode_09_test() {
  assert Ok([0, 9]) == decode("moxr")
}

pub fn encode_10_test() {
  assert Ok("nWqP") == encode([1, 0])
}

pub fn decode_10_test() {
  assert Ok([1, 0]) == decode("nWqP")
}

pub fn encode_20_test() {
  assert Ok("tSyw") == encode([2, 0])
}

pub fn decode_20_test() {
  assert Ok([2, 0]) == decode("tSyw")
}

pub fn encode_30_test() {
  assert Ok("eX68") == encode([3, 0])
}

pub fn decode_30_test() {
  assert Ok([3, 0]) == decode("eX68")
}

pub fn encode_40_test() {
  assert Ok("rxCY") == encode([4, 0])
}

pub fn decode_40_test() {
  assert Ok([4, 0]) == decode("rxCY")
}

pub fn encode_50_test() {
  assert Ok("sV8a") == encode([5, 0])
}

pub fn decode_50_test() {
  assert Ok([5, 0]) == decode("sV8a")
}

pub fn encode_60_test() {
  assert Ok("uf2K") == encode([6, 0])
}

pub fn decode_60_test() {
  assert Ok([6, 0]) == decode("uf2K")
}

pub fn encode_70_test() {
  assert Ok("7Cdk") == encode([7, 0])
}

pub fn decode_70_test() {
  assert Ok([7, 0]) == decode("7Cdk")
}

pub fn encode_80_test() {
  assert Ok("3aWP") == encode([8, 0])
}

pub fn decode_80_test() {
  assert Ok([8, 0]) == decode("3aWP")
}

pub fn encode_90_test() {
  assert Ok("m2xn") == encode([9, 0])
}

pub fn decode_90_test() {
  assert Ok([9, 0]) == decode("m2xn")
}

pub fn encode_1_2_3_test() {
  assert Ok("86Rf07") == encode([1, 2, 3])
}

pub fn decode_1_2_3_test() {
  assert Ok([1, 2, 3]) == decode("86Rf07")
}

pub fn decode_id_with_invalid_character_test() {
  assert Error(Nil) == decode("1235*a")
}

pub fn decode_id_with_invalid_character_2_test() {
  assert Error(Nil) == decode("1235a?")
}

pub fn decode_id_with_invalid_character_3_test() {
  assert Error(Nil) == decode(" 1235")
}

pub fn roundtrip_test() {
  let numbers = int.range(99, -1, [], list.prepend)
  let assert Ok(encoded) = encode(numbers)
  let assert Ok(decoded) = decode(encoded)
  assert decoded == numbers
}

pub fn roundtrip_with_big_numbers_test() {
  let numbers = [
    0, 0, 0, 1, 2, 3, 100, 1000, 100_000, 1_000_000, 9_007_199_254_740_991,
  ]
  let assert Ok(encoded) = encode(numbers)
  let assert Ok(decoded) = decode(encoded)
  assert decoded == numbers
}

pub fn encode_negative_numbers_test() {
  assert Error(Nil) == encode([-1])
}

pub fn encode_100_test() {
  assert Ok("86u") == encode([100])
}

pub fn decode_100_test() {
  assert Ok([100]) == decode("86u")
}

pub fn encode_1000_test() {
  assert Ok("pnd") == encode([1000])
}

pub fn decode_1000_test() {
  assert Ok([1000]) == decode("pnd")
}

pub fn encode_10_000_test() {
  assert Ok("RHEA") == encode([10_000])
}

pub fn decode_10_000_test() {
  assert Ok([10_000]) == decode("RHEA")
}

pub fn encode_min_length_6_test() {
  assert Ok("86Rf07") == encode_with([1, 2, 3], minimum_length: 6)
}

pub fn decode_min_length_6_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07", minimum_length: 6)
}

pub fn encode_min_length_7_test() {
  assert Ok("86Rf07x") == encode_with([1, 2, 3], minimum_length: 7)
}

pub fn decode_min_length_7_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07x", minimum_length: 7)
}

pub fn encode_min_length_8_test() {
  assert Ok("86Rf07xd") == encode_with([1, 2, 3], minimum_length: 8)
}

pub fn decode_min_length_8_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07xd", minimum_length: 8)
}

pub fn encode_min_length_9_test() {
  assert Ok("86Rf07xd4") == encode_with([1, 2, 3], minimum_length: 9)
}

pub fn decode_min_length_9_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07xd4", minimum_length: 9)
}

pub fn encode_min_length_10_test() {
  assert Ok("86Rf07xd4z") == encode_with([1, 2, 3], minimum_length: 10)
}

pub fn decode_min_length_10_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07xd4z", minimum_length: 10)
}

pub fn encode_min_length_11_test() {
  assert Ok("86Rf07xd4zB") == encode_with([1, 2, 3], minimum_length: 11)
}

pub fn decode_min_length_11_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07xd4zB", minimum_length: 11)
}

pub fn encode_min_length_12_test() {
  assert Ok("86Rf07xd4zBm") == encode_with([1, 2, 3], minimum_length: 12)
}

pub fn decode_min_length_12_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07xd4zBm", minimum_length: 12)
}

pub fn encode_min_length_13_test() {
  assert Ok("86Rf07xd4zBmi") == encode_with([1, 2, 3], minimum_length: 13)
}

pub fn decode_min_length_13_test() {
  assert Ok([1, 2, 3]) == decode_with("86Rf07xd4zBmi", minimum_length: 13)
}

pub fn encode_min_length_62_test() {
  assert Ok("86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM")
    == encode_with([1, 2, 3], minimum_length: 62)
}

pub fn decode_min_length_62_test() {
  assert Ok([1, 2, 3])
    == decode_with(
      "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM",
      minimum_length: 62,
    )
}

pub fn encode_min_length_63_test() {
  assert Ok("86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy")
    == encode_with([1, 2, 3], minimum_length: 63)
}

pub fn decode_min_length_63_test() {
  assert Ok([1, 2, 3])
    == decode_with(
      "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy",
      minimum_length: 63,
    )
}

pub fn encode_min_length_64_test() {
  assert Ok("86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf")
    == encode_with([1, 2, 3], minimum_length: 64)
}

pub fn decode_min_length_64_test() {
  assert Ok([1, 2, 3])
    == decode_with(
      "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf",
      minimum_length: 64,
    )
}

pub fn encode_min_length_65_test() {
  assert Ok("86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1")
    == encode_with([1, 2, 3], minimum_length: 65)
}

pub fn decode_min_length_65_test() {
  assert Ok([1, 2, 3])
    == decode_with(
      "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1",
      minimum_length: 65,
    )
}

pub fn encode_00_to_alphabet_length_test() {
  assert Ok("SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu")
    == encode_with([0, 0], minimum_length: 62)
}

pub fn decode_00_to_alphabet_length_test() {
  assert Ok([0, 0])
    == decode_with(
      "SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu",
      minimum_length: 62,
    )
}

pub fn encode_01_to_alphabet_length_test() {
  assert Ok("n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc")
    == encode_with([0, 1], minimum_length: 62)
}

pub fn decode_01_to_alphabet_length_test() {
  assert Ok([0, 1])
    == decode_with(
      "n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc",
      minimum_length: 62,
    )
}

pub fn encode_02_to_alphabet_length_test() {
  assert Ok("tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ")
    == encode_with([0, 2], minimum_length: 62)
}

pub fn decode_02_to_alphabet_length_test() {
  assert Ok([0, 2])
    == decode_with(
      "tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ",
      minimum_length: 62,
    )
}

pub fn encode_03_to_alphabet_length_test() {
  assert Ok("eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE")
    == encode_with([0, 3], minimum_length: 62)
}

pub fn decode_03_to_alphabet_length_test() {
  assert Ok([0, 3])
    == decode_with(
      "eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE",
      minimum_length: 62,
    )
}

pub fn encode_04_to_alphabet_length_test() {
  assert Ok("rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX")
    == encode_with([0, 4], minimum_length: 62)
}

pub fn decode_04_to_alphabet_length_test() {
  assert Ok([0, 4])
    == decode_with(
      "rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX",
      minimum_length: 62,
    )
}

pub fn encode_05_to_alphabet_length_test() {
  assert Ok("sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2")
    == encode_with([0, 5], minimum_length: 62)
}

pub fn decode_05_to_alphabet_length_test() {
  assert Ok([0, 5])
    == decode_with(
      "sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2",
      minimum_length: 62,
    )
}

pub fn encode_06_to_alphabet_length_test() {
  assert Ok("uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0")
    == encode_with([0, 6], minimum_length: 62)
}

pub fn decode_06_to_alphabet_length_test() {
  assert Ok([0, 6])
    == decode_with(
      "uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0",
      minimum_length: 62,
    )
}

pub fn encode_07_to_alphabet_length_test() {
  assert Ok("74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy")
    == encode_with([0, 7], minimum_length: 62)
}

pub fn decode_07_to_alphabet_length_test() {
  assert Ok([0, 7])
    == decode_with(
      "74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy",
      minimum_length: 62,
    )
}

pub fn encode_08_to_alphabet_length_test() {
  assert Ok("30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS")
    == encode_with([0, 8], minimum_length: 62)
}

pub fn decode_08_to_alphabet_length_test() {
  assert Ok([0, 8])
    == decode_with(
      "30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS",
      minimum_length: 62,
    )
}

pub fn encode_09_to_alphabet_length_test() {
  assert Ok("moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin")
    == encode_with([0, 9], minimum_length: 62)
}

pub fn decode_09_to_alphabet_length_test() {
  assert Ok([0, 9])
    == decode_with(
      "moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin",
      minimum_length: 62,
    )
}
