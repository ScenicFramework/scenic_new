Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Scenic.Gen.ComponentTest do
  use ExUnit.Case, async: false
  @moduletag :gen_component

  import ScenicNew.MixHelper
  import ExUnit.CaptureIO

  @component_module "TestComponent"
  @component_name "test_component"

  test "gen.component" do
    in_project("new with defaults", "my_app", fn _mix_project ->
      output = capture_io(fn -> Mix.Tasks.Scenic.Gen.Component.run([@component_module]) end)
      module_definition = "defmodule MyApp.Component.#{@component_module} do"
      assert_file("lib/components/#{@component_name}.ex", module_definition)
      assert output =~ "Created component #{@component_module}."
    end)
  end

  test "gen.component inside umbrella" do
    in_project("umbrella", "my_umbrella", ["--umbrella"], Mix.Tasks.New, fn _mix_project ->
      func = fn -> Mix.Tasks.Scenic.Gen.Component.run([]) end
      assert_raise Mix.Error, func
    end)
  end

  test "gen.component with app" do
    in_project("new with app", "my_app", ["--module", "My.App"], fn _mix_project ->
      args = [@component_module, "--app", "My.App"]
      output = capture_io(fn -> Mix.Tasks.Scenic.Gen.Component.run(args) end)
      assert output =~ "Created component #{@component_module}."
      module_definition = "defmodule My.App.Component.#{@component_module} do"
      assert_file("lib/components/#{@component_name}.ex", module_definition)
    end)
  end

  test "gen.component without args displays help" do
    in_project("help", "help", fn _mix_project ->
      output1 = capture_io(fn -> Mix.Tasks.Scenic.Gen.Component.run([]) end)
      output2 = capture_io(fn -> Mix.Tasks.Help.run(["scenic.gen.component"]) end)
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
