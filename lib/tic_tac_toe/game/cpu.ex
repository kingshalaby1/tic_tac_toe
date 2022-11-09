defmodule TicTacToe.Game.Cpu do
  @moduledoc """
  CPU logic, stupid for now
  """

  alias TicTacToe.Game.Session
  def next_move(game, {user, cpu} = stats) do
    target = check_horizontal(stats) || check_vertical(stats) || random(stats)

          Session.play(game, :cpu, target)
  end

  defp check_horizontal({user, cpu}) do
    Enum.group_by(user, fn {x, _} -> x end)
    |> Enum.reduce(nil, fn {row, list}, acc ->
      if Enum.count(list) == 2, do: find_empty_horizontal(list, row, cpu)
    end)
  end

  defp check_vertical({user, cpu}) do
    Enum.group_by(user, fn {_, x} -> x end)
    |> Enum.reduce(nil, fn {col, list}, acc ->
      if Enum.count(list) == 2, do: find_empty_vertical(list, col, cpu)
    end)
  end

  defp find_empty_horizontal(list, row, cpu_list) do
    [target] = 0..2
    |> Enum.reject( fn n -> {row, n} in list end)
    if {row, target} in cpu_list, do: nil, else: {row, target}
  end

  defp find_empty_vertical(list, col, cpu_list) do
    [target] = 0..2
               |> Enum.reject( fn n -> {n, col} in list end)
    if {target, col} in cpu_list, do: nil, else: {target, col}
  end

  defp random({user, cpu}) do
    all_slots = [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 1}, {2, 2}]
    all_occupied = user ++ cpu
    available_slots = all_slots -- all_occupied
    Enum.take_random(available_slots, 1)
    |> hd()


  end
  
end
