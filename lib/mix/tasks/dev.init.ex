defmodule Mix.Tasks.Dev.Init do
  use Mix.Task

  @requirements ["app.start"]
  def run(_) do
    TestHelpers.get_user()
    Mix.shell().info("Init dev data")
  end
end
