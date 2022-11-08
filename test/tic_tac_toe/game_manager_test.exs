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

  test "user can play" do
    user1 = user(1)
    user2 = user(2)
    {:ok, user1, game} = GameManager.start_game_session(user1)
    {:ok, user2, game} = GameManager.join_game(game, user2)
    assert {:ok, :next, _} = GameManager.player_turn(game, user1, {1, 2})
  end

  test "it returns error when user plays invalid cell" do
    user1 = user(1)
    user2 = user(2)
    {:ok, user1, game} = GameManager.start_game_session(user1)
    {:ok, user2, game} = GameManager.join_game(game, user2)
    assert {:error, :invalid_cell} == GameManager.player_turn(game, user1, {1, 3})
    assert {:error, :invalid_cell} == GameManager.player_turn(game, user1, {-1, 1})
  end

  test "it returns error when user plays while it's not his turn" do
    user1 = user(5)
    user2 = user(6)
    {:ok, user1, game} = GameManager.start_game_session(user1)
    {:ok, user2, game} = GameManager.join_game(game, user2)
    assert {:error, :invalid_user} == GameManager.player_turn(game, user2, {1, 1})
    assert game.turn == user1.id

    assert {:ok, :next, game2} = GameManager.player_turn(game, user1, {1, 1})
    refute game2.turn == user1.id

    assert {:error, :invalid_user} == GameManager.player_turn(game2, user1, {1, 2})
  end

  test "user wins" do
    user1 = user(5)
    user2 = user(6)
    {:ok, user1, game} = GameManager.start_game_session(user1)
    {:ok, user2, game} = GameManager.join_game(game, user2)
    GameManager.player_turn(game, user1, {0, 0})
    GameManager.player_turn(game, user2, {1, 0})
    GameManager.player_turn(game, user1, {0, 1})
    GameManager.player_turn(game, user2, {1, 1})
    assert {:ok, :winner, user1} == GameManager.player_turn(game, user1, {0, 2})

  end

  def user(id) do
    %User{id: id}
  end
  
end
