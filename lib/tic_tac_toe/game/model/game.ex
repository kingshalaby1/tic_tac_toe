defmodule TicTacToe.Model.Game do
  @moduledoc """
      domain model
  """

  defstruct [:id, :user1, :user2, :turn]

  def new(user) do
    %__MODULE__{
      id: UUID.uuid4(),
      user1: user.id,
      turn: user.id

    }
  end


  def check(user_id, cell, state) do
    state
    |> validate_move(user_id, cell)
    |> commit_move
    |> check_for_winner
    |> check_for_draw
  end

  defp validate_move(state, :cpu, cell) do
    {:ok, state, :cpu, cell}
  end
  defp validate_move(state, user_id, cell) do
    id = state.game.user1
    other = case user_id do
      ^id -> state.game.user2
      _ -> state.game.user1
    end
    if Enum.find(state.stats[other], &(&1==cell)) || Enum.find(state.stats[user_id], &(&1==cell)) do
      {:error, :cell_already_taken}
      else
      {:ok, state, user_id, cell}
    end
  end

  defp commit_move({:ok, state, user_id, cell}) do
    new_stats = Map.update(state.stats, user_id, [cell], fn list -> [cell | list] end)
    state = Map.update!(state, :stats, fn _ -> new_stats end)
    state = Map.update!(state, :game, fn game -> switch_turn(game) end)

    if user_id == :cpu, do: Phoenix.PubSub.broadcast(TicTacToe.PubSub, state.game.id, {:cpu_checked, cell})

    {:ok, state, user_id}

  end

  defp commit_move(other), do: other

  defp switch_turn(%{user1: user1, turn: turn} = game) do
    Map.update!(game, :turn, fn _ -> if turn == user1, do: game.user2, else: user1 end)
  end

  defp check_for_winner({:ok, state, user_id}) do
    user_stats = state.stats[user_id]

    checks = [
      check_horizontal(user_stats),
      check_vertical(user_stats),
      check_diagonal(user_stats)
    ]
    if Enum.any?(checks) do
      {:ok, :winner, user_id}
      else
      {:ok, :next, state}
    end
  end

  defp check_for_winner(other), do: other

  defp check_for_draw({:ok, :next, %{stats: stats} = state}) do
    count = Enum.reduce(stats, 0, fn {_, v}, acc ->
      acc + Enum.count(v)
    end)
    if count == 9 do
      {:ok, :draw}
    else
      {:ok, :next, state}
    end

  end

  defp check_for_draw(other), do: other


  defp check_horizontal(user_stats) do
    Enum.group_by(user_stats, fn {x, _} -> x end)
    |> Enum.any?(fn {_, v} -> Enum.count(v) > 2 end)
  end

  defp check_vertical(user_stats) do
    Enum.group_by(user_stats, fn {_, y} -> y end)
    |> Enum.any?(fn {_, v} -> Enum.count(v) > 2 end)
  end

  defp check_diagonal(user_stats) do
    diagonal_sets = [[{0, 0}, {1, 1}, {2, 2}], [{0, 2}, {1, 1}, {2, 0}]]
    Enum.any?(diagonal_sets, fn list -> list -- user_stats == [] end)

  end

end
