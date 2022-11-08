defmodule TicTacToe.Game.GameManagerTest do

  use ExUnit.Case, async: true

  alias TicTacToe.Model.User
  alias TicTacToe.Model.Game
  alias TicTacToe.GameManager
  test "user can create new session" do
    user = user(1)
    assert {:ok, updated_user, game} = GameManager.start_game_session(user)
    assert game.user1 == user.id
    assert updated_user.id == user.id
    assert updated_user.in_game == game.id
  end

  def user(id) do
    %User{id: id}
  end
  
end
