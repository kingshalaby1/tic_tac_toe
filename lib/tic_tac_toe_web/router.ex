defmodule TicTacToeWeb.Router do
  use TicTacToeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TicTacToeWeb do
    pipe_through :api
  end
end
