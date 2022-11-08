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

  def join_game(game, user) do
    user = %{user | in_game: game.id}
#    game = Map.put(game, :user2, user.id)
    {:ok, game} = Session.join(game, user)
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
         {:ok, user} <- validate_user(game, user) do
            Session.play(game, user, cell)
    else
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
