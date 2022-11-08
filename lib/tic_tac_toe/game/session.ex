defmodule TicTacToe.Game.Session do
  @moduledoc false
  use GenServer

  alias TicTacToe.Model.Game

#  @initial_board [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 1}, {2, 2}]
  def start_link(game) do
    GenServer.start_link(__MODULE__, game, name: {:global, game.id})
  end

  def join(game, user) do
      GenServer.call({:global, game.id}, {:join, user})
  end

  def play(game, user, cell) do
    GenServer.call({:global, game.id}, {:check, user, cell})
  end



  @impl true
  def init(game) do
#    Map.put(game_state, :board, @initial_board)
    state = %{game: game, stats: %{game.user1 => []}}
    {:ok, state}
  end

  @impl true
  def handle_call({:join, user}, _from, state) do

    state = Map.update!(state, :game, fn game -> Map.put(game, :user2, user.id) end)
    state = Map.update!(state, :stats, fn stats -> Map.put(stats, user.id, []) end)
    {:reply, {:ok, state.game}, state}

  end


  @impl true
  def handle_call({:check, user, cell}, _from, state) do
      case Game.check(user, cell, state) do
        {:ok, :winner, user} ->
          {:reply, {:ok, :winner, user}, []}
        {:ok, :next, state} ->
          {:reply, {:ok, :next, state.game}, state}
      end

  end


end
