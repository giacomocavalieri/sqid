import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

/// An alphabet that can be used to encode and decode Sqids.
/// The alphabet used to encode numbers determines which characters can be used
/// in their string representation.
/// You can build one using the [`alphabet`](#alphabet) function.
///
/// ## Examples
///
/// If you want Sqids that only contains lowercase letters you can define an
/// alphabet like this:
///
/// ```gleam
/// let assert Ok(alphabet) =
///   sqid.alphabet("abcdefghijklmnopqrstuvwxyz")
/// ```
///
pub opaque type Alphabet {
  Alphabet(
    /// This goes from index to character. If the alphabet were `"abc"`, then
    /// this would be `dict.from_list([#(0, "a"), #(1, "b"), #(2, "c")])`.
    letters: dict.Dict(Int, String),
  )
}

/// The options used to encode and decode a Sqid.
/// You can create one from a valid `Alphabet` with the [`new`](#new) function.
///
pub opaque type Options {
  Options(
    /// The alphabet determining which characters can appear in the generated
    /// Sqid.
    alphabet: Alphabet,
    /// The minimum length that a Sqid must have.
    /// This value must be between 0 and 255, any value lower or higher is
    /// considered either 0 or 255.
    minimum_length: Int,
    /// A list of words that must not appear in the generated Sqid.
    blocklist: List(String),
  )
}

/// Creates a new alphabet from the letters making up the given string.
/// An alphabet is what defines what characters can end up in a generated Sqid.
///
/// This function will fail if:
/// - The alphabet has less than 3 characters
/// - The alphabet contains repeated characters
/// - The alphabet has multi-byte characters
///
/// ## Examples
///
/// If you want Sqids that only contains lowercase letters you can define an
/// alphabet like this:
///
/// ```gleam
/// let assert Ok(alphabet) =
///   sqid.alphabet("abcdefghijklmnopqrstuvwxyz")
/// ```
///
/// ```gleam
/// assert Error(Nil) == sqid.alphabet("wibble")
///   as "wrong alphabet: it contains duplicates"
///
/// assert Error(Nil) == sqid.alphabet("dziękuję")
///   as "wrong alphabet: it contains non ascii characters"
///
/// assert Error(Nil) == sqid.alphabet("01")
///   as "wrong alphabet: it contains less than 3 characters"
/// ```
///
pub fn alphabet(string: String) -> Result(Alphabet, Nil) {
  let letters = string.to_graphemes(string)
  use <- bool.guard(when: has_duplicates(letters), return: Error(Nil))
  use <- bool.guard(when: list.any(letters, is_multi_byte), return: Error(Nil))

  case letters {
    [] | [_] | [_, _] -> Error(Nil)
    _ -> {
      let letters =
        list.index_fold(letters, dict.new(), fn(acc, letter, index) {
          dict.insert(acc, index, letter)
        })
      Ok(shuffle_alphabet(Alphabet(letters:)))
    }
  }
}

fn is_multi_byte(string: String) -> Bool {
  string.byte_size(string) > 1
}

fn has_duplicates(list: List(a)) -> Bool {
  has_duplicates_loop(list, set.new())
}

fn has_duplicates_loop(list: List(a), seen_so_far: Set(a)) -> Bool {
  case list {
    [] -> False
    [first, ..rest] ->
      case set.contains(seen_so_far, first) {
        True -> True
        False -> has_duplicates_loop(rest, set.insert(seen_so_far, first))
      }
  }
}

/// Creates an `Options` object from a valid alphabet.
/// `Options` determine how Sqids are encoded and decoded.
///
/// If you want to change the generated Sqids you can also use:
/// - [`set_minimum_length`](#set_minimum_length): to pick a minimum length for
///   the generated Sqids.
/// - [`set_blocklist`](#set_blocklist): to specify a blocklist of words that
///   will not end up in any of the generated Sqids.
///
pub fn new(alphabet: Alphabet) -> Options {
  Options(alphabet:, minimum_length: 0, blocklist: [])
}

/// Sets the minimum length of the generated Sqids.
/// The value must be between 0 and 255. Any value lower than 0 is considered
/// as 0, while any value higher than 255 is considered as 255.
///
pub fn set_minimum_length(options: Options, minimum_length: Int) -> Options {
  Options(
    ..options,
    minimum_length: int.clamp(minimum_length, min: 0, max: 255),
  )
}

/// Sets the list of blocked words that cannot appear inside any of the
/// generated Sqids.
/// This is useful if you want to make sure a generated Sqid cannot contain
/// profanities.
///
/// There's a couple of things to note:
/// - The blocklist is case insensitive. If `"gleam"` is a blocked word,
///   generated Sqids will not contain any of `"gLeaM"`, `"GLEAM"`, `"GLeam"`,
///   ... and so on.
/// - All words in the blocklist must be more than three characters long, any
///   word shorter than that will be ignored.
///
pub fn set_blocklist(options: Options, blocklist: List(String)) -> Options {
  let alphabet_string = alphabet_to_string(options.alphabet)
  let blocklist =
    list.fold(blocklist, [], fn(blocklist, word) {
      // The block list is case insensitive, all words are turned to lowercase.
      let word = string.lowercase(word)
      case string.to_graphemes(word) {
        // Words that are less than three characters are ignored.
        [] | [_] | [_, _] -> blocklist
        // Otherwise they can be added. But, we can preemptively remove all the
        // strings that contain letters that are not in the alphabet.
        // Since we only generate
        letters ->
          case list.all(letters, string.contains(alphabet_string, _)) {
            True -> [word, ..blocklist]
            False -> blocklist
          }
      }
    })

  Options(..options, blocklist:)
}

/// Encodes a list of numbers into a readable string using the given options.
/// This function might fail if it's not possible to generate a string that is
/// not excluded by the options' blocklist.
///
pub fn encode(options: Options, numbers: List(Int)) -> Result(String, Nil) {
  case numbers {
    [] -> Ok("")
    _ -> do_encode(options, numbers, 0)
  }
}

fn do_encode(
  options: Options,
  numbers: List(Int),
  attempts: Int,
) -> Result(String, Nil) {
  case attempts >= dict.size(options.alphabet.letters) {
    // We've reached the maximum number of attempts to generate an id and
    // couldn't generate one!
    True -> Error(Nil)
    False -> {
      // Otherwise the algorithm works as follow: we start by shifting the
      // alphabet, and get the first separator from this shifted one.
      let alphabet_size = dict.size(options.alphabet.letters)
      use offset <- result.try(semi_random_offset(options.alphabet, numbers))
      let offset = offset % alphabet_size
      let offset = { offset + attempts } % alphabet_size
      let alphabet = shift_alphabet(options.alphabet, offset)
      let id = alphabet_separator(alphabet)

      // We then have to reverse the alphabet and iterate over all the numbers
      // encoding each one into a single id.
      let alphabet = reverse_alphabet(alphabet)
      let #(id, alphabet) = encode_numbers(numbers, alphabet, id)

      // Then we keep adding pad characters to reach the minimum character
      // limit.
      let id = pad_to_length(id, options.minimum_length, alphabet)

      // Finally we check if the id contains any word that is in the block list.
      // If it does it is discarded and we try generating a new one!
      case is_blocked_id(id, options) {
        True -> do_encode(options, numbers, attempts + 1)
        False -> Ok(id)
      }
    }
  }
}

/// Returns true if the id contains any of the words that are in the options'
/// block list.
/// Checking is case insensitive: if `"gleam"` is not allowed then `"GLeaM"`
/// would be rejected as well.
///
fn is_blocked_id(id: String, options: Options) -> Bool {
  let id = string.lowercase(id)
  let id_size = string.byte_size(id)
  list.any(options.blocklist, satisfying: fn(blocked_word) {
    let blocked_word_size = string.byte_size(blocked_word)
    case blocked_word_size > id_size {
      // If the word is longer than the id, then it's impossible for the id to
      // contain it, we keep going.
      True -> False
      // Otherwise we have to check if the blocked word is inside the id.
      // For short ids/words, we only check if they are exactly the same,
      // otherwise we would be excluding way too many ids.
      False if id_size <= 3 || blocked_word_size <= 3 -> id == blocked_word
      // Otherwise we just check as regular if the id contains the word.
      False -> string.contains(id, blocked_word)
    }
  })
}

fn encode_numbers(
  numbers: List(Int),
  alphabet: Alphabet,
  id: String,
) -> #(String, Alphabet) {
  case numbers {
    [] -> #(id, alphabet)
    [last] -> #(id <> number_to_id(last, alphabet), alphabet)
    // If the number is not the last one, we need to turn it into a string id,
    // and then add a separator character before the next one.
    [first, ..rest] -> {
      let id = id <> number_to_id(first, alphabet)
      let id = id <> alphabet_separator(alphabet)
      // Before dealing with each number we need to shuffle the alphabet.
      let alphabet = shuffle_alphabet(alphabet)
      encode_numbers(rest, alphabet, id)
    }
  }
}

fn number_to_id(number: Int, alphabet: Alphabet) -> String {
  number_to_id_loop(number, alphabet, [])
}

fn number_to_id_loop(
  number: Int,
  alphabet: Alphabet,
  acc: List(String),
) -> String {
  // The number is used as an index to pick a letter from the alphabet.
  // The only thing we need to be careful with is that the first character in
  // the alphabet (the one at index 0), is used as the separator.
  // So we can only pick letters with indices `[1, alphabet_size - 1]`.
  let alphabet_size = dict.size(alphabet.letters) - 1
  let assert Ok(letter) =
    dict.get(alphabet.letters, { number % alphabet_size } + 1)

  // We then divide the number by the alphabet size and keep going picking
  // letters until we get to 0.
  // Why do we do that? Ask the Sqid folks, that's just how this works!
  let acc = [letter, ..acc]
  let number =
    float.floor(int.to_float(number) /. int.to_float(alphabet_size))
    |> float.round

  case number > 0 {
    True -> number_to_id_loop(number, alphabet, acc)
    False -> string.join(acc, "")
  }
}

fn pad_to_length(id: String, length: Int, alphabet: Alphabet) -> String {
  let id_length = string.byte_size(id)
  case id_length < length {
    False -> id
    True -> {
      let id = id <> alphabet_separator(alphabet)
      let missing = length - id_length - 1
      pad_to_length_loop(id, missing, alphabet)
    }
  }
}

fn pad_to_length_loop(id: String, missing: Int, alphabet: Alphabet) -> String {
  case missing > 0 {
    False -> id
    True -> {
      let alphabet = shuffle_alphabet(alphabet)
      let alphabet_size = dict.size(alphabet.letters)
      let slice_size = int.min(missing, alphabet_size)
      let slice = string.slice(alphabet_to_string(alphabet), 0, slice_size)
      let id = id <> slice
      let missing = missing - slice_size
      pad_to_length_loop(id, missing, alphabet)
    }
  }
}

/// Returns the separator of the alphabet, the separator changes based on how
/// the
fn alphabet_separator(alphabet: Alphabet) -> String {
  let assert Ok(separator) = dict.get(alphabet.letters, 0) as "empty alphabet"
  separator
}

/// Shifts the alphabet by the given offset.
/// For example if alphabet is `"abcde"` and I end up shifting it by 2 to the
/// left it ends up being `"cdeab"`.
///
fn shift_alphabet(alphabet: Alphabet, offset: Int) {
  // All values after the offset need to be moved to the start of the alphabet:
  //
  //   index    0 1 2 3 4
  //   letter   a b c d e
  //                  ^ imagine offset is 3
  //
  // We need to move `d` and `e` so that they start from 0 onward, we can do
  // that by subtracting the offset from their index:
  //
  // - `d` goes to `3 - 3` -> `0`
  // - `e` goes to `4 - 3` -> `1`
  //
  // All good! With numbers that come before the offset they'll have to start
  // after all the number that we've moved. How many numbers are we moving?
  // All the numbers that go from `offset` to the end of the alphabet; in this
  // example if would be just two (`d` and `e`). In general that's given by
  // `alphabet_size - offset`.
  //
  // - We can check this works for our example: we're moving
  //   `alphabet_size - offset` -> `5 - 3` -> `2` characters
  // - `a` goes to `0 + 2` -> `2`
  // - `b` goes to `1 + 2` -> `3`
  // - `c` goes to `2 + 2` -> `4`
  let alphabet_size = dict.size(alphabet.letters)
  let letters =
    dict.fold(alphabet.letters, dict.new(), fn(letters, index, letter) {
      let new_index = case index < offset {
        True -> alphabet_size - offset + index
        False -> index - offset
      }
      dict.insert(letters, new_index, letter)
    })
  Alphabet(letters:)
}

/// This computes an offset from a list of numbers, the Sqid spec calls this
/// "semi random": it's random looking but it's actually deterministically
/// decided by the numbers and alphabet we pass as arguments.
/// This returns an error if any of the numbers is negative.
fn semi_random_offset(
  alphabet: Alphabet,
  numbers: List(Int),
) -> Result(Int, Nil) {
  let alphabet_size = dict.size(alphabet.letters)
  list.try_fold(numbers, #(list.length(numbers), 0), fn(pair, number) {
    let #(acc, index) = pair
    case number < 0 {
      True -> Error(Nil)
      False -> {
        let assert Ok(letter_value) =
          letter_value(alphabet.letters, number % alphabet_size)
          as "index outside of dictionary"

        Ok(#(letter_value + index + acc, index + 1))
      }
    }
  })
  |> result.map(fn(pair) { pair.0 })
}

/// Given a dictionary of letters this returns the codepoint value of the letter
/// at the given index.
/// This would fail if:
/// - the index is not included in the dictionary
/// - the dictionary value is an empty string
///
/// We only ever use this internally after validating an alphabet and making
/// sure that all the entries are single letters, so under this assumption it
/// should never fail.
fn letter_value(
  letters: dict.Dict(Int, String),
  index: Int,
) -> Result(Int, Nil) {
  dict.get(letters, index)
  |> result.map(string.to_utf_codepoints)
  |> result.try(list.first)
  |> result.map(string.utf_codepoint_to_int)
}

/// Shuffles an alphabet.
/// Don't be fooled by the name: the shuffle might look random, but it's
/// actually deterministic. Given an alphabet its shuffled version is always
/// going to be the same.
///
fn shuffle_alphabet(alphabet: Alphabet) -> Alphabet {
  let letters =
    shuffle_alphabet_loop(alphabet.letters, 0, dict.size(alphabet.letters) - 1)
  Alphabet(letters:)
}

fn shuffle_alphabet_loop(
  letters: dict.Dict(Int, String),
  i: Int,
  j: Int,
) -> dict.Dict(Int, String) {
  case j <= 0 {
    True -> letters
    False -> {
      let assert Ok(i_value) = letter_value(letters, i) as "i always in range"
      let assert Ok(j_value) = letter_value(letters, j) as "j always in range"
      let r = { i * j + i_value + j_value } % dict.size(letters)

      let assert Ok(old_i) = dict.get(letters, i) as "i always in range"
      let assert Ok(old_r) = dict.get(letters, r) as "r always in range"
      let letters = dict.insert(letters, i, old_r) |> dict.insert(r, old_i)
      shuffle_alphabet_loop(letters, i + 1, j - 1)
    }
  }
}

/// This reverses an alphabet: if the initial alphabet is "abcd", the reversed
/// alphabet is going to be "dcba".
fn reverse_alphabet(alphabet: Alphabet) -> Alphabet {
  let size = dict.size(alphabet.letters)
  let letters =
    dict.fold(alphabet.letters, dict.new(), fn(letters, index, letter) {
      dict.insert(letters, size - 1 - index, letter)
    })

  Alphabet(letters:)
}

fn alphabet_to_string(alphabet: Alphabet) -> String {
  dict.to_list(alphabet.letters)
  |> list.sort(fn(one, other) { int.compare(one.0, other.0) })
  |> list.map(fn(pair) { pair.1 })
  |> string.join(with: "")
}

// --- DECODING ----------------------------------------------------------------

/// Decodes a Sqid into the list of integers that was used to generate it.
/// To decode a Sqid, always use the same options that were used to encode it,
/// otherwise you will get nonsense results!
///
/// This function will fail if the Sqid has carachters that are not allowed by
/// these options, meaning that the Sqid was encoded with a different alphabet.
///
pub fn decode(options: Options, sqid: String) -> Result(List(Int), Nil) {
  case string.pop_grapheme(sqid) {
    // The string is empty, so it was encoded from the empty list
    Error(_) -> Ok([])
    // Otherwise we use the prefix to get back to the original offset we used to
    // shift the alphabet, so we can shift it back into its original form.
    Ok(#(separator, sqid)) ->
      case index(alphabet_to_string(options.alphabet), of: separator) {
        // The Sqid's character is not in the alphabet. This means it was
        // encoded using a different alphabet.
        Error(_) -> Error(Nil)
        Ok(offset) ->
          shift_alphabet(options.alphabet, offset)
          |> reverse_alphabet
          |> decode_loop(sqid, [])
      }
  }
}

fn decode_loop(
  alphabet: Alphabet,
  sqid: String,
  numbers: List(Int),
) -> Result(List(Int), Nil) {
  let separator = alphabet_separator(alphabet)
  case string.split(sqid, separator) {
    // If the string is empty, or the first chunk is empty we're done (the rest
    // are junk padding characters).
    [] | ["", ..] -> Ok(list.reverse(numbers))
    // If the chunk is empty we're done, the rest are junk padding characters.
    [id, ..rest] ->
      case id_to_number(id, alphabet) {
        Error(_) -> Error(Nil)
        Ok(number) -> {
          let numbers = [number, ..numbers]
          let alphabet = shuffle_alphabet(alphabet)
          let sqid = string.join(rest, with: separator)
          decode_loop(alphabet, sqid, numbers)
        }
      }
  }
}

fn id_to_number(id: String, alphabet: Alphabet) -> Result(Int, Nil) {
  let alphabet_size = dict.size(alphabet.letters) - 1
  let alphabet_string = alphabet_to_string(alphabet)

  list.try_fold(string.to_graphemes(id), 0, fn(acc, letter) {
    use index <- result.try(index(alphabet_string, of: letter))
    Ok(acc * alphabet_size + index - 1)
  })
}

fn index(string: String, of separator: String) -> Result(Int, Nil) {
  use #(before, _) <- result.try(string.split_once(string, on: separator))
  Ok(string.byte_size(before))
}
