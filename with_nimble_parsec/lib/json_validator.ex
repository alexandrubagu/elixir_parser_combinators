defmodule JsonValidator do
  import NimbleParsec

  @moduledoc """
  Json grammar

  <Json> ::= <Object>
         | <Array>

  <Object> ::= '{' '}'
           | '{' <Members> '}'

  <Members> ::= <Pair>
            | <Pair> ',' <Members>

  <Pair> ::= String ':' <Value>

  <Array> ::= '[' ']'
          | '[' <Elements> ']'

  <Elements> ::= <Value>
             | <Value> ',' <Elements>

  <Value> ::= String
          | Number
          | <Object>
          | <Array>
          | true
          | false
          | null
  """

  integer = integer(min: 1)

  string =
    ignore(string(~S(")))
    |> ascii_string([?a..?z], min: 1)
    |> ignore(string(~S(")))

  boolean =
    choice([
      string("true"),
      string("false")
    ])

  null = string("null")

  comma = string(",") |> optional(string(" "))

  defcombinatorp :value,
                 choice([
                   integer,
                   string,
                   boolean,
                   null,
                   parsec(:array),
                   parsec(:object)
                 ])

  defcombinatorp :elements,
                 choice([
                   parsec(:value)
                   |> concat(ignore(comma))
                   |> concat(parsec(:elements)),
                   parsec(:value)
                 ])

  defcombinatorp :array,
                 choice([
                   empty()
                   |> ignore(ascii_char([?[]))
                   |> ignore(ascii_char([?]])),
                   empty()
                   |> ignore(ascii_char([?[]))
                   |> parsec(:elements)
                   |> ignore(ascii_char([?]]))
                 ])

  defcombinatorp :pair,
                 string
                 |> ignore(ascii_char([?:]))
                 |> ignore(optional(string(" ")))
                 |> parsec(:value)

  defcombinatorp :members,
                 choice([
                   parsec(:pair)
                   |> concat(ignore(comma))
                   |> concat(parsec(:members)),
                   parsec(:pair)
                 ])

  defcombinatorp :object,
                 choice([
                   empty()
                   |> ignore(ascii_char([?{]))
                   |> ignore(ascii_char([?}])),
                   empty()
                   |> ignore(ascii_char([?{]))
                   |> parsec(:members)
                   |> ignore(ascii_char([?}]))
                 ])

  json =
    choice([
      parsec(:object),
      parsec(:array)
    ])

  defparsec :parse, json, debug: true
end
