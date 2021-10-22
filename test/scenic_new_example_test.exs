Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Scenic.NewExampleTest do
  use ExUnit.Case, async: false

  import ScenicNew.MixHelper
  import ExUnit.CaptureIO

  @app_name "scenic_demo"
  @module_name "ScenicDemo"

  test "new.example with defaults" do
    in_tmp("new with defaults", fn ->
      assert capture_io(fn ->
               Mix.Tasks.Scenic.New.Example.run([@app_name])

               assert_file("#{@app_name}/README.md")
               assert_file("#{@app_name}/.formatter.exs")
               assert_file("#{@app_name}/.gitignore")
               assert_file("#{@app_name}/assets/images/attribution.txt")
               assert_file("#{@app_name}/assets/images/fairy_grove.jpg")
               assert_file("#{@app_name}/assets/images/cyanoramphus_zealandicus_1849.jpg")

               assert_file("#{@app_name}/config/config.exs", fn file ->
                 assert file =~ "config :#{@app_name}, :viewport"
                 assert file =~ "size: {800, 600}"

                 assert file =~
                          "default_scene: #{@module_name}.Scene.Components"

                 assert file =~ ", title: \"#{@app_name}\""
               end)

               assert_file("#{@app_name}/lib/#{@app_name}.ex", fn file ->
                 assert file =~ "defmodule #{@module_name} do"
                 assert file =~ "Application.get_env(:#{@app_name}, :viewport)"
                 assert file =~ "#{@module_name}.PubSub.Supervisor"
               end)

               assert_file("#{@app_name}/lib/scenes/components.ex")
               assert_file("#{@app_name}/lib/scenes/sensor.ex")
               assert_file("#{@app_name}/lib/scenes/sensor_spec.ex")
               assert_file("#{@app_name}/lib/scenes/primitives.ex")
               assert_file("#{@app_name}/lib/scenes/transforms.ex")
               assert_file("#{@app_name}/lib/scenes/fills.ex")
               assert_file("#{@app_name}/lib/scenes/strokes.ex")
               assert_file("#{@app_name}/lib/scenes/sprites.ex")
               assert_file("#{@app_name}/lib/components/nav.ex")
               assert_file("#{@app_name}/lib/components/notes.ex")
               assert_file("#{@app_name}/lib/pubsub/supervisor.ex")
               assert_file("#{@app_name}/lib/pubsub/temperature.ex")

               assert_file("#{@app_name}/mix.exs", fn file ->
                 assert file =~ "mod: {#{@module_name}, []}"

                 assert file =~ "{:scenic, \"~> 0.11.0-beta.0\"}"
                 assert file =~ "{:scenic_driver_local, \"~> 0.11.0-beta.0\"}"
               end)
             end) =~ "Your Scenic project was created successfully."
    end)
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name cannot be scenic", fn ->
      Mix.Tasks.Scenic.New.Example.run(["scenic"])
    end

    assert_raise Mix.Error, ~r"Application name cannot be scenic", fn ->
      Mix.Tasks.Scenic.New.Example.run(["folder/scenic"])
    end

    assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter,", fn ->
      Mix.Tasks.Scenic.New.Example.run(["007invalid"])
    end

    assert_raise Mix.Error, ~r"Application name must start with a lowercase ASCII letter, ", fn ->
      Mix.Tasks.Scenic.New.Example.run(["valid", "--app", "007invalid"])
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Scenic.New.Example.run(["valid", "--module", "not.valid"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Example.run(["string"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Example.run(["string", "chars"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Example.run(["valid", "--app", "mix"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Scenic.New.Example.run(["valid", "--module", "String"])
    end
  end

  test "new without args" do
    assert capture_io(fn -> Mix.Tasks.Scenic.New.Example.run([]) end) =~
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
        Mix.Tasks.Scenic.New.Example.run([@app_name])
        assert_received {:mix_shell, :yes?, [^msg]}
      end
    end)

    Mix.shell(shell)
  end
end
