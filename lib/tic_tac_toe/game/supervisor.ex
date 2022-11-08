defmodule TicTacToe.Game.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(game) do
    # If MyWorker is not using the new child specs, we need to pass a map:
#     spec = %{id: TicTacToe.Game.Session, start: {TicTacToe.Game.Session, :start_link, [game]}}
    spec = {TicTacToe.Game.Session, game}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def terminate_child(game) do
    pid = :global.whereis_name(game.id)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end



  @impl true
  def init(_args) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end
end