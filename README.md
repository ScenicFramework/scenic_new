# ScenicNew

The `scenic.new` mix task, which generates a starter application for
you. This is the easiest way to set up a new Scenic project.


### Installing scenic.new

`scenic.new` is intended to be used as an installed elixir package. To install
the v0.11 beta, run the following command in your terminal.

```
mix archive.install hex scenic_new 0.11.0-beta.0
```

Then you can create the example applications.

```
mix scenic.new simple
mix scenic.new.example demo
```


## Erlang/Elixir versions

Please note, it currently needs OTP 21 and Elixir 1.7. If you have trouble
compiling, please check that you are running those versions first.

## Install Prerequisites

The design of Scenic goes to great lengths to minimize its dependencies to just
the minimum. Namely, it needs Erlang/Elixir and OpenGL.

Rendering your application into a window on your local computer (MacOS, Ubuntu
and others) is done by the `scenic_driver_local` driver. It uses the GLFW and
GLEW libraries to connect to OpenGL.

The instructions below assume you have already installed Elixir/Erlang. If you
need to install Elixir/Erlang there are instructions on the [elixir-lang
website](https://elixir-lang.org/install.html).

### Installing on MacOS

The easiest way to install on MacOS is to use Homebrew. Just run the following
in a terminal:

```bash
brew update
brew install glfw3 glew pkg-config
```

Once these components have been installed, you should be able to build the
`scenic_driver_local` driver.

### Installing on Ubuntu 16

The easiest way to install on Ubuntu is to use apt-get. Just run the following:

```bash
sudo apt-get update
sudo apt-get install pkgconf libglfw3 libglfw3-dev libglew1.13 libglew-dev
```

Once these components have been installed, you should be able to build the
`scenic_driver_local` driver.

### Installing on Ubuntu 18

The easiest way to install on Ubuntu is to use apt-get. Just run the following:

```bash
sudo apt-get update
sudo apt-get install pkgconf libglfw3 libglfw3-dev libglew2.0 libglew-dev
```

Once these components have been installed, you should be able to build the
`scenic_driver_local` driver.

### Installing on Arch Linux

`glew` and `glfw-x11` are available in [Extra](https://www.archlinux.org/packages/extra/x86_64/glew/) and [Community](https://www.archlinux.org/packages/community/x86_64/glfw/), respectively. Ensure that these are enabled in your `pacman.conf`, then run:

```bash
sudo pacman -S pkgconf glew glfw-x11
```

Once these components have been installed, you should be able to build the
`scenic_driver_local` driver.

### Installing on Fedora

The easiest way to install on Fedora is to use `dnf`. Just run the following,
to install development toolchain, and build/runtime graphics libraries:

```bash
sudo dnf install pkgconf glew-devel glfw-devel
```

Once these components have been installed, you should be able to build the
`scenic_driver_local` driver.

### Installing on FreeBSD

The easiest way to install on FreeBSD is to use `pkg`. Just run the following,
to install development toolchain, and build/runtime graphics libraries:

```bash
sudo pkg install devel/gmake devel/pkgconf devel/elixir-hex devel/rebar3 \
  graphics/glew graphics/glfw
```

Once these components have been installed, you should be able to build the
`scenic_driver_local` driver.

### Installing on NixOS 18.09

The easiest way to install on NixOS is with a custom shell. Create a file titled `shell.nix` that includes the following:

```nix
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inherit (lib) optional optionals;
  elixir = beam.packages.erlangR21.elixir_1_7;
in

mkShell {
  buildInputs = [
    elixir
    glew glfw
    git
    pkgconfig
    x11
    xorg.libpthreadstubs
    xorg.libXcursor
    xorg.libXdmcp
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXrandr
    xorg.xrandr
  ];
}
```

Then use `nix-shell` to build and run the shell as your development environment:

```bash
nix-shell shell.nix
```

### Installing on Windows

First, make sure to have installed Visual Studio with its "Desktop development with C++" package.

Next, you need to download the Windows binaries for [GLFW](https://www.glfw.org/download.html) and [GLEW](http://glew.sourceforge.net/index.html) manually.

Locate your Visual Studio installation directory. Two folders will be required for the next steps:

* The **Include** folder: `{Visual Studio Path}\VC\Tools\MSVC\{version number}\include`
* The **Lib** folder: `{Visual Studio Path}\VC\Tools\MSVC\{version number}\lib\amd64` (possibly `x64` for some installs?)

Open the GLFW package you downloaded. Extract the contents of the packaged `include` folder to your Visual Studio **Include** folder. Next to the `include` folder, you'll also find several `lib-vc20xx` folders. Select the closest match to your Visual Studio version and extract the contents to your **Lib** folder.

Lastly, install the GLEW package. Find the packaged `include` folder and extract its contents to your **Include** folder as well. You should now have two new folders in your **Include** folder: `GL` and `GLFW`. Now navigate to `lib\Release\x64` in the GLEW package. Copy all `*.lib` files to your **Lib** folder. Finally, navigate to `bin\Release\amd64` and copy `glew32.dll` to your `Windows\system32` folder.

## Install `scenic.new`

```bash
mix archive.install hex scenic_new
```

To build and run scenic applications, you will also need to install a few
dependencies. See the [Getting
started](https://hexdocs.pm/scenic/getting_started.html#install-dependencies)
for more information.

### Build and install locally

To build and install this archive locally ensure any previous archive versions
are removed:

```bash
mix archive.uninstall scenic_new
```

Then run:

```bash
cd scenic_new
MIX_ENV=prod mix do archive.build, archive.install
```

## Build the Basic Application

First, navigate the command-line to the directory where you want to create your
new Scenic application. Then run the following commands: (change `my_app` to
the name of your application)

```bash
mix scenic.new my_app
cd my_app
mix do deps.get, scenic.run
```

This will create a bare-bones application


## Build the Example Application

First, navigate the command-line to the directory where you want to create your
new Scenic application. Then run the following commands: (change `my_app` to
the name of your application)

```bash
mix scenic.new.example my_app
cd my_app
mix do deps.get, scenic.run
```

## Build a Basic [Nerves](https://nerves-project.org/) Application

To add Scenic to a Nerves project, you should first set up Nerves and create a new
Nerves project using the nerves generator.

See the Nerves [Getting Started](https://hexdocs.pm/nerves/getting-started.html) documentation.

After creating a new Nerves app, run the following command from within the app's directory.

```bash
mix scenic.setup
```

Then follow the next-step instructions that get printed out in the terminal window.


## The Example Application

The starter application created by the generator above shows the basics of
building a Scenic application. It has four scenes, two components, and a
simulated sensor.

Scene | Description
--- | ---
Splash | The Splash scene is configured to run when the application is started in the `config/config.exs` file. It runs a simple animation, then transitions to the Sensor scene. It also shows how intercept basic user input to exit the scene early.
Sensor | The Sensor scene depicts a simulated temperature sensor. The sensor is always running and updates it's data through the `Scenic.SensorPubSub` server.
Primitives | The Primitives scenes displays an overview of the basic primitive types and some of the styles that can be applied to them.
Components | The Components scene shows the basic components that come with Scenic. The crash button will cause a match error that will crash the scene, showing how the supervision tree restarts the scene. It also shows how to receive events from components.

Component | Description
--- | ---
Nav | The navigation bar at the top of the main scenes shows how to navigate between scenes and how to construct a simple component and pass a parameter to it. Note that it references a clock, creating a nested component. The clock is positioned by dynamically querying the width of the ViewPort
Notes | The notes section at the bottom of each scene is very simple and also shows passing in custom data from the parent.

The simulated temperature sensor doesn't collect any actual data, but does show
how you would set up a real sensor and publish data from it into the
`Scenic.SensorPubSub` service.

## What to read next

Next, you should read the guides describing the overall Scenic
structure. This is in the documentation for [Scenic
itself](https://github.com/boydm/scenic).
