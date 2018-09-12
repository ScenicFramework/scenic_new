# ScenicNew

The scenic.new mix task, which generates out a starter application for you. This is the easiest way to set up a new Scenic project.

## Erlang/Elixir versions

Please note, it currently needs OTP 21 and Elixir 1.7. If you have trouble compiling, please check that you are running those versions first.

## Install Prerequisites

The design of Scenic goes to great lengths to minimize its dependencies to just the minimum. Namely, it needs Erlang/Elixir and OpenGL.

Rendering your application into a window on your local computer (MacOS, Ubuntu and others) is done by the `scenic_driver_glfw` driver. It uses the GLFW and GLEW libraries to connect to OpenGL.

The instructions below assume you have already installed Elixir/Erlang. If you need to install Elixir/Erlang there are instructions on the [elixir-lang website](https://elixir-lang.org/install.html).


### Installing on MacOS

The easiest way to install on MacOS is to use Homebrew. Just run the following in a terminal:

```bash
brew update
brew install glfw3 glew pkg-config
```


Once these components have been installed, you should be able to build the `scenic_driver_glfw` driver.


### Installing on Ubuntu 16

The easiest way to install on Ubuntu is to use apt-get. Just run the following:

```bash
sudo apt-get update
sudo apt-get install pkgconf libglfw3 libglfw3-dev libglew1.13 libglew-dev
```

Once these components have been installed, you should be able to build the
`scenic_driver_glfw` driver.

### Installing on Ubuntu 18

The easiest way to install on Ubuntu is to use apt-get. Just run the following:

```bash
sudo apt-get update
sudo apt-get install pkgconf libglfw3 libglfw3-dev libglew2.0 libglew-dev
```

Once these components have been installed, you should be able to build the
`scenic_driver_glfw` driver.


## Install `scenic.new`

```bash
mix archive.install hex scenic_new
```

To build and run scenic applications, you will also need to install a few dependencies. See the [Getting started](https://hexdocs.pm/scenic/getting_started.html#install-dependencies) for more information.

## Build the Starter App


First, navigate the command-line to the directory where you want to create your new Scenic app. Then run the following commands:  (change `my_app` to the name of your app...)

```bash
mix scenic.new my_app
cd my_app
mix do deps.get, scenic.run
```


## Running and Debugging

Once the app and its dependencies are set up, there are two main ways to run it.

If you want to run your app under IEx so that you can debug it, simply run

```bash
iex -S mix
```

This works just like any other Elixir application.

If you want to run your app outside of iex, you should start it like this:

```bash
mix scenic.run
```

## The Starter App

The starter app created by the generator above shows the basics of building a Scenic application. It has four scenes, two components, and a simulated sensor.

Scene | Description
--- | ---
Splash | The Splash scene is configured to run when the app is started in the `config/config.exs` file. It runs a simple animation, then transitions to the Sensor scene. It also shows how intercept basic user input to exit the scene early.
Sensor | The Sensor scene depicts a simulated temperature sensor. The sensor is always running and updates it's data through the `Scenic.SensorPubSub` server.
Primitives | The Primitives scenes displays an overview of the basic primitive types and some of the styles that can be applied to them.
Components | The Components scene shows the basic components that come with Scenic. The crash button will cause a match error that will crash the scene, showing how the supervison tree restarts the scene. It also shows how to receive events from components.

Component | Description
--- | ---
Nav | The nav bar at the top of the main scenes shows how to navigate between scenes and how to construct a simple component and pass a parameter to it. Note that it references a clock, creating a nested component. The clock is positioned by dynamically querying the width of the ViewPort
Notes | The notes section at the bottom of each scene is very simple and also shows passing in custom data from the parent.

The simulated temperature sensor doesn't collect any actual data, but does show how you would set up a real sensor and publish data from it into the Scenic.SensorPubSub service.

## What to read next

Next, you should read guides describing the overall Scenic structure. This is in the documentation for Scenic itself
