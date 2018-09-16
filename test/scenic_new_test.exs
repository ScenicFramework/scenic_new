defmodule Mix.Tasks.Scenic.NewTest do
  use ExUnit.Case, async: true

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter,", fn ->
      Mix.Tasks.Scenic.New.run(["007invalid"])
    end

    assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter, ", fn ->
      Mix.Tasks.Scenic.New.run(["valid", "--app", "007invalid"])
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Scenic.New.run(["valid", "--module", "not.valid"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.run(["string"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.run(["string", "chars"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.run(["valid", "--app", "mix"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.run(["valid", "--module", "String"])
    end
  end
end
