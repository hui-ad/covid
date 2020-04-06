defmodule Covid.DohTracker.SiteCrawler do
  @moduledoc """
  Responsible for triggering the crawling of the site and syncing of the archived pages to git
  """
  use GenServer
  alias Covid.DohTracker.SiteFetcher

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ignored_state, name: __MODULE__)
  end

  def milliseconds_to_next_fetch(now \\ DateTime.utc_now()) do
    last_fetch_timestamp =
      [
        SiteFetcher.latest_archive(:home_page),
        SiteFetcher.latest_archive(:details_page)
      ]
      |> Enum.min(DateTime)

    next_fetch =
      Enum.max(
        [
          Timex.add(last_fetch_timestamp, Timex.Duration.from_hours(1)),
          now
        ],
        DateTime
      )

    DateTime.diff(next_fetch, now, :millisecond)
    |> max(0)
  end

  @impl GenServer
  def init(_opts) do
    Process.send(self(), :crawl, [])

    schedule_crawl(milliseconds_to_next_fetch())
    {:ok, nil}
  end

  @impl GenServer
  def handle_info(:crawl, state) do
    SiteFetcher.mirror(:home_page)
    SiteFetcher.mirror(:details_page)
    SiteFetcher.commit_archives()
    SiteFetcher.git_pull_push()

    {:noreply, state}
  end

  def should_crawl?(page, now \\ DateTime.utc_now()) do
    next_fetch = next_fetch_at(page)
    DateTime.compare(next_fetch, now) in [:lt]
  end

  def next_fetch_at(page) do
    fetched_at = SiteFetcher.latest_archive(page)
    Timex.add(fetched_at, Timex.Duration.from_hours(1))
  end

  def schedule_crawl(milliseconds \\ 1_000 * 60 * 60) do
    Process.send_after(self(), :crawl, milliseconds)
  end
end
