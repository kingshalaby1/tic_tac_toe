defmodule TicTacToe.GameManager do
  @moduledoc """
  the public API
  """
  alias TicTacToe.Model.Game
  alias TicTacToe.Model.User
  alias TicTacToe.Game.Supervisor


  # @spec start_game(user) :: {:ok, game}
  def start_game_session(%User{} = user) do
    game = Game.new(user)
    {:ok, _server_id} = Supervisor.start_child(game)
    user = %{user | in_game: game.id}
    {:ok, user, game}
  end

  def end_game_session(game, user) do
    if user.id == game.user1 do
      Supervisor.terminate_child(game)
      else
      {:error, :not_permitted}
    end
  end




  
end
