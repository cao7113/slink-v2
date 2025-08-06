defmodule Mix.Tasks.Dev.Init do
  use Mix.Task

  @requirements ["app.start"]
  def run(_) do
    TestHelpers.init_data()
    Mix.shell().info("Init dev data")
  end
end
