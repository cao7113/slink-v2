defmodule Mix.Tasks.Slink.Hi do
  use Mix.Task

  def run(_) do
    Mix.shell().info("Hi slink")
  end
end
