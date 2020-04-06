defmodule Covid.DohTracker.HomepageParser do
  import Meeseeks.XPath
  use Timex

  @version NaiveDateTime.new(2020, 4, 5, 12, 0, 0)
  @xpath_selectors %{
    total_cases:
      "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[1]/dl/dd[1]/span[2]",
    # newly_reported_cases:
    #   "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[1]/dl/dd[1]/span[2]",
    hospitalized:
      "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[2]/dl/dd[1]/span[2]",
    deaths: "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[2]/dl/dd[2]/span[2]",
    pending: "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[1]/dl/dd[6]/span[2]",
    residents_diagnosed_abroad:
      "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[1]/dl/dd[7]/span[2]",
    released_from_isolation:
      "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[2]/dl/dd[3]/span[2]",
    last_updated_at: "//*[@id=\"kt-layout-id_ed170a-9d\"]/div/div[2]/div/div/div/div[2]/dl/dd[4]"
  }

  def parse_home_page do
    {:ok, html} = Covid.DohTracker.get_main_html_text(:home_page)
    parse(html)
  end

  # Example text: "Cumulative totals as of 12:00pm, April 5, 2020"
  def parse_last_updated_at_datetime(text) do
    %{"datetime" => last_updated_at} =
      Regex.named_captures(
        ~r/^Cumulative totals as of (?<datetime>.*)$/u,
        text
      )

    # https://hexdocs.pm/timex/Timex.Format.DateTime.Formatters.Default.html#content
    {:ok, result} = Timex.parse(last_updated_at, "{h12}:{m}{am}, {Mfull} {D}, {YYYY}")
    datetime = Timex.to_datetime(result, "Pacific/Honolulu")

    {datetime}
  end

  # Example text: "371 (20 newly reported)"
  def parse_total_newly_reported_cases(text) do
    %{"total" => total_cases, "new" => newly_reported_cases} =
      Regex.named_captures(
        ~r/(?<total>\d+) \((?<new>\d+) newly reported\)/u,
        text
      )

    {total_cases_value, ""} = Integer.parse(total_cases)
    {newly_reported_cases_value, ""} = Integer.parse(newly_reported_cases)

    {
      total_cases_value,
      newly_reported_cases_value
    }
  end

  def parse(html) do
    document = Meeseeks.parse(html)

    Enum.reduce(@xpath_selectors, %{}, fn
      {:total_cases, selector}, acc ->
        result = Meeseeks.one(document, xpath(selector))
        text = Meeseeks.text(result)

        {total_cases, newly_reported_cases} = parse_total_newly_reported_cases(text)

        Map.merge(acc, %{
          total_cases: total_cases,
          newly_reported_cases: newly_reported_cases
        })

      {:last_updated_at, selector}, acc ->
        result = Meeseeks.one(document, xpath(selector))
        text = Meeseeks.text(result)

        {last_updated_at} = parse_last_updated_at_datetime(text)

        Map.put(acc, :last_updated_at, last_updated_at)

      {key, selector}, acc ->
        result = Meeseeks.one(document, xpath(selector))
        text = Meeseeks.text(result)
        {value, ""} = Integer.parse(text)

        Map.put(acc, key, value)
    end)
  end
end
