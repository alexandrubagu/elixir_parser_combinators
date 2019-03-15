defmodule JsonValidatorTest do
  use ExUnit.Case

  describe "string_decoder/0" do
    test "decodes a string" do
      assert {:ok, "test"} == Saul.validate("test", JsonValidator.string_decoder())
    end

    test "returns an error when trying to decode an atom, number, boolean, list, map" do
      values = [:atom, nil, 1, true, [1, "a"], %{a: 1}]

      for value <- values do
        assert {:error,
                %Saul.Error{
                  position: nil,
                  reason: "predicate failed",
                  term: {:term, value},
                  validator: "string"
                }} == Saul.validate(value, JsonValidator.string_decoder())
      end
    end
  end

  describe "number_decoder/0" do
    test "decodes a number" do
      assert {:ok, 1} == Saul.validate(1, JsonValidator.number_decoder())
    end

    test "returns an error when trying to decode an atom, string, boolean, list, map" do
      values = [:atom, nil, "test", true, [1, "a"], %{a: 1}]

      for value <- values do
        assert {:error,
                %Saul.Error{
                  position: nil,
                  reason: "predicate failed",
                  term: {:term, value},
                  validator: "number"
                }} == Saul.validate(value, JsonValidator.number_decoder())
      end
    end
  end

  describe "boolean_decoder/0" do
    test "decodes a boolean" do
      assert {:ok, true} == Saul.validate(true, JsonValidator.boolean_decoder())
    end

    test "returns an error when trying to decode an atom, nil, string, number, list, map" do
      values = [:atom, nil, "test", 2, [1, "a"], %{a: 1}]

      for value <- values do
        assert {:error,
                %Saul.Error{
                  position: nil,
                  reason: "predicate failed",
                  term: {:term, value},
                  validator: "boolean"
                }} == Saul.validate(value, JsonValidator.boolean_decoder())
      end
    end
  end

  describe "nil_decoder/0" do
    test "decodes nil" do
      assert {:ok, nil} == Saul.validate(nil, JsonValidator.nil_decoder())
    end

    test "returns an error when trying to decode an atom, true, string, number, list, map" do
      values = [:atom, true, "test", 2, [1, "a"], %{a: 1}]

      for value <- values do
        assert {:error,
                %Saul.Error{
                  position: nil,
                  reason: "predicate failed",
                  term: {:term, value},
                  validator: "null"
                }} == Saul.validate(value, JsonValidator.nil_decoder())
      end
    end
  end

  describe "list_decoder/0" do
    test "decodes a list" do
      assert {:ok, []} == Saul.validate([], JsonValidator.list_decoder())

      assert {:ok, [1, "test", true, nil, ["a", 1, [false, ["v"]]]]} ==
               Saul.validate(
                 [1, "test", true, nil, ["a", 1, [false, ["v"]]]],
                 JsonValidator.list_decoder()
               )
    end

    test "returns an error when trying to decode an atom or map" do
      assert {:error, _} =
               Saul.validate(
                 [1, "test", true, nil, ["a", [[:atom]]]],
                 JsonValidator.list_decoder()
               )
    end
  end

  describe "object_decoder/0" do
    test "decodes a list" do
      assert {:ok, %{}} == Saul.validate(%{}, JsonValidator.object_decoder())

      assert {:ok, %{"test" => %{"key" => [1, true, false, ["a"]], "new_key" => 10}}} ==
               Saul.validate(
                 %{"test" => %{"key" => [1, true, false, ["a"]], "new_key" => 10}},
                 JsonValidator.object_decoder()
               )
    end

    test "returns an error when trying to decode an atom" do
      assert {:error, _} =
               Saul.validate(
                 %{"test" => %{"key" => [1, true, false, [[:atom]]]}},
                 JsonValidator.object_decoder()
               )
    end
  end

  describe "json_decoder" do
    test "decodes a json" do
      filenames = ["test/array.json", "test/object.json"]

      for filename <- filenames do
        data =
          filename
          |> File.read!()
          |> Jason.decode!()

        assert {:ok, ^data} = Saul.validate(data, JsonValidator.json_decoder())
      end
    end
  end
end
