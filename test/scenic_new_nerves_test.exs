Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Scenic.New.NervesTest do
  use ExUnit.Case, async: false

  import ScenicNew.MixHelper
  import ExUnit.CaptureIO

  @app_name "scenic_demo"
  @module_name "ScenicDemo"

  test "new.example with defaults" do
    in_tmp("new with defaults", fn ->
      assert capture_io(fn ->
               Mix.Tasks.Scenic.New.Nerves.run([@app_name])

               assert_file("#{@app_name}/README.md")
               assert_file("#{@app_name}/.formatter.exs")
               assert_file("#{@app_name}/.gitignore")

               assert_file("#{@app_name}/config/config.exs", fn file ->
                 assert file =~ "config :nerves, :firmware, rootfs_overlay: \"rootfs_overlay\""
               end)

               assert_file("#{@app_name}/config/host.exs", fn file ->
                 assert file =~ "config :#{@app_name}, :viewport"
                 assert file =~ "size: {800, 480}"
                 assert file =~ "opts: [scale: 1.0]"

                 assert file =~ "default_scene: {#{@module_name}.Scene.SysInfo, nil}"

                 assert file =~ "title: \"MIX_TARGET=host, app = :#{@app_name}\""
               end)

               assert_file("#{@app_name}/config/rpi3.exs", fn file ->
                 assert file =~ "config :#{@app_name}, :viewport"
                 assert file =~ "size: {800, 480}"
                 assert file =~ "opts: [scale: 1.0]"

                 assert file =~ "default_scene: {#{@module_name}.Scene.SysInfo, nil}"

                 assert file =~ "device: \"FT5406 memory based driver\""
               end)

               assert_file("#{@app_name}/lib/#{@app_name}.ex", fn file ->
                 assert file =~ "defmodule #{@module_name}.Application do"
                 assert file =~ "Application.get_env(:#{@app_name}, :viewport)"
               end)

               assert_file("#{@app_name}/lib/scenes/crosshair.ex")
               assert_file("#{@app_name}/lib/scenes/sys_info.ex")

               assert_file("#{@app_name}/mix.exs", fn file ->
                 assert file =~ "{:scenic, \"~> 0.10\"}"
                 assert file =~ "{:scenic_driver_local, \"~> 0.1\", targets: :host}"

                 assert file =~
                          "{:scenic_driver_nerves_touch, \"~> 0.10\", targets: @all_targets}"
               end)
             end) =~ "Your Scenic project was created successfully."
    end)
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name cannot be scenic", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["scenic"])
    end

    assert_raise Mix.Error, ~r"Application name cannot be scenic", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["folder/scenic"])
    end

    assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter,", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["007invalid"])
    end

    assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter, ", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["valid", "--app", "007invalid"])
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["valid", "--module", "not.valid"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["string"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["string", "chars"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["valid", "--app", "mix"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Nerves.run(["valid", "--module", "String"])
    end
  end

  test "new without args" do
    assert capture_io(fn -> Mix.Tasks.Scenic.New.Nerves.run([]) end) =~
             "Generates a starter Scenic application."
  end

  test "new check for directory existence" do
    shell = Mix.shell()

    in_tmp("check for directory existence", fn ->
      File.mkdir!(@app_name)

      # Send Mix messages to the current process instead of performing IO
      Mix.shell(Mix.Shell.Process)
      msg = "The directory \"scenic_demo\" already exists. Are you sure you want to continue?"

      assert_raise Mix.Error, ~r"Please select another directory for installation", fn ->
        # The shell ask if we want to continue. We will say no.
        send(self(), {:mix_shell_input, :yes?, false})
        Mix.Tasks.Scenic.New.Nerves.run([@app_name])
        assert_received {:mix_shell, :yes?, [^msg]}
      end
    end)

    Mix.shell(shell)
  end
end
