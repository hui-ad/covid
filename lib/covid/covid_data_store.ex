defmodule Covid.CovidDataStore do
  use GenServer

  defmodule State do
    defstruct [:data]
  end

  def start_link(_opts \\ nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    schedule_refresh()
    {:ok, nil, {:continue, :fetch_data}}
  end

  def get do
    GenServer.call(__MODULE__, :get)
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

  @impl GenServer
  def handle_info(:refresh_data, state) do
    schedule_refresh()
    {:ok, data} = Covid.CovidTrackingData.fetch()
    {:noreply, %State{state | data: data}}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh_data, 1000 * 60 * 60)
  end
end
