Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Scenic.Gen.ComponentTest do
  use ExUnit.Case, async: false
  @moduletag :gen_component

  import ScenicNew.MixHelper
  import ExUnit.CaptureIO

  @component_name "test_component"
  @component_module_name "TestComponent"
  @app_name "scenic_new"
  @module_name "ScenicNew"

  test "gen.scene" do
    func = fn ->
      Mix.Tasks.Scenic.New.run([@app_name])
      Mix.Tasks.Scenic.Gen.Component.run([@component_module_name])

      assert_file("lib/components/#{@component_name}.ex", fn file ->
        assert file =~ "defmodule #{@module_name}.Component.#{@component_module_name} do"
      end)
    end

    in_tmp("new with defaults", fn ->
      assert capture_io(func) =~ "Created component #{@component_module_name}."
    end)
  end

  # test "new with invalid args" do
  #   assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter,", fn ->
  #     Mix.Tasks.Scenic.Gen.Scene.run(["007invalid"])
  #   end

  #   assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter, ", fn ->
  #     Mix.Tasks.Scenic.Gen.Scene.run(["valid", "--app", "007invalid"])
  #   end

  #   assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
  #     Mix.Tasks.Scenic.Gen.Scene.run(["valid", "--module", "not.valid"])
  #   end

  #   assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
  #     Mix.Tasks.Scenic.Gen.Scene.run(["string"])
  #   end

  #   assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
  #     Mix.Tasks.Scenic.Gen.Scene.run(["string", "chars"])
  #   end

  #   assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
  #     Mix.Tasks.Scenic.Gen.Scene.run(["valid", "--app", "mix"])
  #   end

  #   assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
  #     Mix.Tasks.Scenic.Gen.Scene.run(["valid", "--module", "String"])
  #   end
  # end

  # test "new without args" do
  #   assert capture_io(fn -> Mix.Tasks.Scenic.Gen.Scene.run([]) end) =~
  #   "Generates Scene boilerplate for a new scene."
  # end
end
