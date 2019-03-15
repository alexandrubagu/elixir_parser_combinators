defmodule JsonValidatorTest do
  use ExUnit.Case

  test "test json validator" do
    JsonValidator.parse(~S([1, 2,["a", ["b", [3, 4]]]]))

    JsonValidator.parse(~S({"a": 1, "b": {"c": 2}, "d": [1, [{"z": "c"}]]}))
    |> IO.inspect()
  end
end
