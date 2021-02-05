Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Scenic.Gen.SceneTest do
  use ExUnit.Case, async: false
  @moduletag :gen_scene

  import ScenicNew.MixHelper
  import ExUnit.CaptureIO

  @scene_name "test_scene"
  @scene_module_name "TestScene"
  @app_name "scenic_demo"
  @module_name "ScenicDemo"

  test "gen.scene" do
    Application.put_env(String.to_atom(@app_name), :namespace, String.to_atom(@module_name))

    func = fn ->
      Mix.Tasks.Scenic.New.run([@app_name])
      Mix.Tasks.Scenic.Gen.Scene.run([@scene_module_name])

      assert_file("lib/scenes/#{@scene_name}.ex", fn file ->
        assert file =~ "defmodule #{@module_name}.Scene.#{@scene_module_name} do"
      end)
    end

    in_tmp("new with defaults", fn ->
      assert capture_io(func) =~ "Created scene #{@scene_module_name}."
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
