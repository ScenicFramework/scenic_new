Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Scenic.Gen.SceneTest do
  use ExUnit.Case, async: false
  @moduletag :gen_scene

  import ScenicNew.MixHelper
  import ExUnit.CaptureIO

  @scene_module "TestScene"
  @scene_name "test_scene"

  test "gen.scene" do
    in_project("new with defaults", "my_app", fn _mix_project ->
      output = capture_io(fn -> Mix.Tasks.Scenic.Gen.Scene.run([@scene_module]) end)
      module_definition = "defmodule MyApp.Scene.#{@scene_module} do"
      assert_file("lib/scenes/#{@scene_name}.ex", module_definition)
      assert output =~ "Created scene #{@scene_module}."
    end)
  end

  test "gen.scene inside umbrella" do
    in_project("umbrella", "my_umbrella", ["--umbrella"], Mix.Tasks.New, fn _mix_project ->
      func = fn -> Mix.Tasks.Scenic.Gen.Scene.run([]) end
      assert_raise Mix.Error, func
    end)
  end

  test "gen.scene with app" do
    in_project("new with app", "my_app", ["--module", "My.App"], fn _mix_project ->
      args = [@scene_module, "--app", "My.App"]
      output = capture_io(fn -> Mix.Tasks.Scenic.Gen.Scene.run(args) end)
      assert output =~ "Created scene #{@scene_module}."
      module_definition = "defmodule My.App.Scene.#{@scene_module} do"
      assert_file("lib/scenes/#{@scene_name}.ex", module_definition)
    end)
  end

  test "gen.scene without args displays help" do
    in_project("help", "help", fn _mix_project ->
      output1 = capture_io(fn -> Mix.Tasks.Scenic.Gen.Scene.run([]) end)
      output2 = capture_io(fn -> Mix.Tasks.Help.run(["scenic.gen.scene"]) end)
      assert output1 == output2
    end)
  end

  defp in_project(tmp_dir, app_name, extra_args \\ [], task \\ Mix.Tasks.Scenic.New, project_func) do
    in_tmp(tmp_dir, fn ->
      capture_io(fn -> task.run([app_name | extra_args]) end)
      app_name |> String.to_atom() |> Mix.Project.in_project(app_name, project_func)
    end)
  end
end
