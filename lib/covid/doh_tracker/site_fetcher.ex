defmodule Covid.DohTracker.SiteFetcher do
  @pages %{
    home_page: "https://health.hawaii.gov/coronavirusdisease2019/",
    details_page:
      "https://health.hawaii.gov/coronavirusdisease2019/what-you-should-know/current-situation-in-hawaii/"
  }

  def run do
    mirror(:home_page)
    mirror(:details_page)
    commit_archives()
    git_pull_push()
  end

  def mirror(page, now \\ NaiveDateTime.utc_now()) do
    url = Map.fetch!(@pages, page)

    cmd = [
      "--page-requisites",
      "--adjust-extension",
      "--no-parent",
      "--convert-links",
      "--wait=1",
      "--retry-connrefused",
      "--output-file=wget-log.txt",
      # "--no-verbose",
      "--directory-prefix=#{prefix(now, page)}",
      url
    ]

    {_, _} = System.cmd("wget", cmd)
  end

  def commit_archives do
    commit_message = """
    Saving archives

    Home page: #{latest_archive(:home_page)}
    Details page: #{latest_archive(:details_page)}
    """

    {_, 0} = System.cmd("git", ["add", "archive"])
    {_, 0} = System.cmd("git", ["commit", "-m", commit_message])
  end

  def git_pull_push do
    # NOTE: This will error if the changes cannot be merged cleanly
    {_, 0} = System.cmd("git", ["pull"])
    {_, 0} = System.cmd("git", ["push"])
  end

  def latest_archive(:home_page) do
    List.first(list_archives().home_page)
  end

  def latest_archive(:details_page) do
    List.first(list_archives().details_page)
  end

  def get_main_html_text(:home_page) do
    archive_timestamp = latest_archive(:home_page)

    File.read(
      "archive/home_page/#{archive_timestamp}/health.hawaii.gov/coronavirusdisease2019/index.html"
    )
  end

  def get_main_html_text(:details_page) do
    archive_timestamp = latest_archive(:details_page)

    File.read(
      [
        "archive",
        "details_page",
        # archive_timestamp,
        # TODO: FIX THIS
        "2020-04-06_05-32",
        "health.hawaii.gov",
        "coronavirusdisease2019",
        "what-you-should-know",
        "current-situation-in-hawaii",
        "index.html"
      ]
      |> Enum.join("/")
      |> IO.inspect(label: "file_path")
    )
  end

  def list_archives do
    with {:ok, details_page_archives} <- File.ls("archive/details_page"),
         {:ok, home_page_archives} <- File.ls("archive/home_page") do
      details_page_archives = Enum.map(details_page_archives, &parse_timestamp/1)
      home_page_archives = Enum.map(home_page_archives, &parse_timestamp/1)

      %{
        home_page: Enum.sort(home_page_archives, {:desc, DateTime}),
        details_page: Enum.sort(details_page_archives, {:desc, DateTime})
      }
    end
  end

  defp prefix(now, page) do
    {{year, month, day}, {hour, minute, _}} = NaiveDateTime.to_erl(now)

    timestamp =
      "#{pad(year, 4)}-#{pad(month, 2)}-#{pad(day, 2)}_#{pad(hour, 2)}-#{pad(minute, 2)}"

    "archive/#{page}/#{timestamp}"
  end

  defp pad(number, digits) do
    to_string(number)
    |> String.pad_leading(digits, "0")
  end

  @doc """
  iex> Covid.DohTracker.SiteCrawler.parse_timestamp("2020-04-06_01-22")
  ~N[2020-04-06 01:22:00]
  """
  def parse_timestamp(timestamp) do
    {:ok, date_time} = Timex.parse(timestamp, "{YYYY}-{0M}-{D}_{h24}-{m}")
    Timex.to_datetime(date_time, "Etc/UTC")
  end
end
