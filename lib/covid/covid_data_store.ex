defmodule Covid.CovidDataStore do
  use GenServer

  defmodule State do
    defstruct [:data]
  end

  def start_link(_opts \\ nil) do
    # test
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, nil, {:continue, :fetch_data}}
  end

  def get do
    # TODO: Store it in state
    GenServer.call(__MODULE__, :get)
    Covid.CovidTrackingData.fetch()
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    %State{data: data} = state
    {:reply, {:ok, data}, state}
  end

  @impl GenServer
  def handle_continue(:fetch_data, _state) do
    {:ok, data} = Covid.CovidTrackingData.fetch()
    {:noreply, %State{data: data}}
  end
end
