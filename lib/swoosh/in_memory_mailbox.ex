defmodule Swoosh.InMemoryMailbox do
  @moduledoc """
  """

  use GenServer

  @doc """
  Starts the InMemoryMailbox server
  """
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Stops the InMemoryMailbox server
  """
  def stop() do
    GenServer.stop(__MODULE__)
  end

  @doc """
  """
  def push(email) do
    GenServer.call(__MODULE__, {:push, email})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def delete_all() do
    GenServer.call(__MODULE__, :delete_all)
  end

  # Callbacks

  def init(_args) do
    {:ok, []}
  end

  def handle_call({:push, email}, _from, state) do
    id = :crypto.rand_bytes(16) |> Base.encode16
    email = email |> Swoosh.Email.header("Message-ID", id)
    {:reply, email, [email] ++ state}
  end

  def handle_call(:pop, _from, [h|t]) do
    {:reply, h, t}
  end

  def handle_call({:get, id}, _from, state) do
    email = Enum.find(state, nil, fn %Swoosh.Email{headers: %{"Message-ID" => mid}} -> mid == id end)
    {:reply, email, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:delete_all, _from, _state) do
    {:reply, :ok, []}
  end

  def handle_call(msg, from, state) do
    super(msg, from, state)
  end

  def handle_cast(msg, state) do
    super(msg, state)
  end
end
