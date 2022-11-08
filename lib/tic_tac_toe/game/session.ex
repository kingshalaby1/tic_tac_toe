defmodule TicTacToe.Game.Session do
  @moduledoc false
  use GenServer

  @initial_board [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 1}, {2, 2}]
  def start_link(game) do
    GenServer.start_link(__MODULE__, game, name: {:global, game.id})
  end

  def check(game_id, user, cell) do
    GenServer.call({:global, game_id}, {:check, user, cell})
  end






  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end


  @impl true
  def handle_call({:check, user, cell}, _from, state) do
    IO.inspect(cell, label: "got >>>>")
    {:reply, cell, state}
  end


end
