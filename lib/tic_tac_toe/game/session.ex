defmodule TicTacToe.Game.Session do
  @moduledoc false
  use GenServer

  alias TicTacToe.Model.Game
  alias TicTacToe.Game.Cpu

  def start_link(game) do
    GenServer.start_link(__MODULE__, game, name: {:global, game.id})
  end

  def join(game, user) do
      GenServer.call({:global, game.id}, {:join, user})
  end

  def play(game, :cpu, cell) do
    GenServer.call({:global, game.id}, {:check, :cpu, cell})
  end
  def play(game, user, cell) do
    GenServer.call({:global, game.id}, {:check, user.id, cell})
  end

  def cpu_play(game) do
    # stats should be in the loop instead of 2 calls for CPU
    {:ok, stats} = GenServer.call({:global, game.id}, :get_opponent_stats)

    Cpu.next_move(game, stats)
  end



  @impl true
  def init(game) do
    state = %{game: game, stats: %{game.user1 => []}}
    {:ok, state}
  end

  @impl true
  def handle_call({:join, user}, _from, state) do

    state = Map.update!(state, :game, fn game -> Map.put(game, :user2, user) end)
    state = Map.update!(state, :stats, fn stats -> Map.put(stats, user, []) end)
    {:reply, {:ok, state.game}, state}

  end


  @impl true
  def handle_call({:check, user, cell}, _from, state) do
      case Game.check(user, cell, state) do
        {:ok, :winner, user} ->
          {:reply, {:ok, :winner, user}, []}
        {:ok, :draw} ->
          {:reply, {:ok, :draw}, []}
        {:ok, :next, state} ->
          {:reply, {:ok, :next, state.game}, state}
        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end

  end

  @impl true
  def handle_call(:get_opponent_stats, _from, state) do
    {:reply, {:ok, {state.stats[state.game.user1], state.stats[state.game.user2]}}, state}
  end


end
