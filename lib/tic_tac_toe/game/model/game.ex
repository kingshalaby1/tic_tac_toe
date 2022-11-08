defmodule TicTacToe.Model.Game do
  @moduledoc """
      domain model
  """

  defstruct [:id, :user1, :user2, :state]

  def new(user) do
    %__MODULE__{
      id: UUID.uuid4(),
      user1: user.id,
      state: :initated
    }
  end
end
