defmodule TicTacToe.GameManager do
  @moduledoc """
  the public API
  """
  alias TicTacToe.Model.Game
  alias TicTacToe.Model.User
  alias TicTacToe.Game.Supervisor
  alias TicTacToe.Game.Session


  # @spec start_game(user) :: {:ok, game}
  def start_game_session(%User{} = user) do
    game = Game.new(user)
    {:ok, _server_id} = Supervisor.start_child(game)
    user = %{user | in_game: game.id}
    {:ok, user, game}
  end

  def join_game(game, :cpu) do
    {:ok, game} = Session.join(game, :cpu)
    {:ok, :cpu, game}
  end

  def join_game(game, user) do
    user = %{user | in_game: game.id}
    {:ok, game} = Session.join(game, user.id)
    {:ok, user, game}
  end



  def end_game_session(game, user) do
    if user.id == game.user1 do
      Supervisor.terminate_child(game)
      else
      {:error, :not_permitted}
    end
  end

  def player_turn(game, user, cell) do
    with {:ok, cell} <- validate_cell(cell),
         {:ok, user} <- validate_user(game, user),
         {:ok, :next, game} <- Session.play(game, user, cell) do
          if(game.turn == :cpu) do
            Session.cpu_play(game)
          else
            {:ok, :next, game}
          end
    else
      {:ok, :winner, ^user} = result ->
        Supervisor.terminate_child(game)
        result
      {:ok, :draw} ->
        Supervisor.terminate_child(game)
        {:ok, :draw}
      error -> error
    end

  end



  defp validate_cell({x, y} = cell) do
    if x in 0..2 && y in 0..2 do
      {:ok, cell}
    else
      {:error, :invalid_cell}
    end
  end

  defp validate_user(game, user) do
    if game.turn == user.id do
      {:ok, user}
    else
      {:error, :invalid_user}
    end
  end




  
end
