defmodule JsonValidator do
  import Saul

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
  def string_decoder, do: named_validator(&is_binary/1, "string")
  def number_decoder, do: named_validator(&is_number/1, "number")
  def boolean_decoder, do: named_validator(&is_boolean/1, "boolean")

  def nil_decoder, do: named_validator(&is_nil/1, "null")

  def element_decoder do
    [
      string_decoder(),
      number_decoder(),
      boolean_decoder(),
      nil_decoder(),
      list_decoder(),
      object_decoder()
    ]
    |> one_of
  end

  def list_decoder, do: named_validator(list_of(lazy(&element_decoder/0)), "list")

  def object_decoder,
    do: named_validator(map_of(lazy(&string_decoder/0), lazy(&element_decoder/0)), "object")

  def json_decoder() do
    [
      list_decoder(),
      object_decoder()
    ]
    |> one_of
  end

  def lazy(decoder_thunk), do: fn val -> validate(val, decoder_thunk.()) end
end
