defmodule Covid.DohTracker.DetailsParser do
  import Meeseeks.XPath
  use Timex
  @version NaiveDateTime.new(2020, 4, 5, 12, 0, 0)
  # I am so sorry
  @xpath_selectors %{
    last_updated_at: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[1]/td/span[2]",
    residents_diagnosed_abroad:
      "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[35]/td[2]",
    county_pending: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[36]/td[2]",
    totals: %{
      # Statewide
      statewide: %{
        total_cases: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[4]/td[2]",
        released_from_isolation:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[5]/td[2]",
        required_hospitalization:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[6]/td[2]",
        deaths: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[7]/td[2]"
      },
      # Hawaii County
      hawaii: %{
        county_total_cases:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[12]/td[2]",
        county_released_from_isolation:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[13]/td[2]",
        county_required_hospitalization:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[14]/td[2]",
        county_deaths: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[15]/td[2]"
      },
      # Honolulu County
      honolulu: %{
        county_total_cases:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[18]/td[2]",
        county_released_from_isolation:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[19]/td[2]",
        county_required_hospitalization:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[20]/td[2]",
        county_deaths: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[21]/td[2]"
      },
      # Kauai County
      kaui: %{
        county_total_cases:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[24]/td[2]",
        county_released_from_isolation:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[25]/td[2]",
        county_required_hospitalization:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[26]/td[2]",
        county_deaths: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[27]/td[2]"
      },
      # Maui County
      maui: %{
        county_total_cases:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[30]/td[2]",
        county_released_from_isolation:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[31]/td[2]",
        county_required_hospitalization:
          "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[32]/td[2]",
        county_deaths: "//*[@id=\"main\"]/div[2]/div[2]/div[2]/center/table/tbody/tr[33]/td[2]"
      }
    }
  }

  defmodule TotalReport do
    defstruct [:name, :total_cases, :released_from_isolation, :required_hospitalization, :deaths]
  end

  def parse_details_page do
    {:ok, html} = Covid.DohTracker.get_main_html_text(:details_page)
    parse(html)
  end

  defp format_report_tuple(:statewide, {:total_cases, value}) do
    {:total_cases, value}
  end

  defp format_report_tuple(_report_name, {key, value}) do
    {num, ""} = Integer.parse(value)

    {key, num}
  end

  def parse(html) do
    document = Meeseeks.parse(html)

    _totals =
      Enum.reduce(@xpath_selectors.totals, %{}, fn
        {report_name, metric_selectors}, totals_acc ->
          report =
            for {metric, selector} <- metric_selectors, into: %{} do
              value = get_xpath_text(document, selector)
              format_report_tuple(report_name, {metric, value})
            end

          Map.put(totals_acc, report_name, report)
      end)
  end

  defp get_xpath_text(document, selector) do
    result = Meeseeks.one(document, xpath(selector))

    Meeseeks.text(result)
  end
end
