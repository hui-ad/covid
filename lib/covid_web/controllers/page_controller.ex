defmodule CovidWeb.PageController do
  use CovidWeb, :controller

  def index(conn, _params) do
    svg = generate_svg()
    render(conn, "index.html", svg: svg)
  end

  def generate_svg do
    {:ok, data} = Covid.CovidDataStore.get()

    plot_content =
      Contex.BarChart.new(to_contex_data(data))
      |> Contex.BarChart.colours(CovidWeb.BarchartHelpers.lookup_colours("themed"))

    plot =
      Contex.Plot.new(400, 300, plot_content)
      |> Contex.Plot.axis_labels("Time", "Positive cases")
      |> Contex.Plot.titles("Covid Tests", nil)

    Contex.Plot.to_svg(plot)
  end

  def to_contex_data(data) do
    Enum.map(data, fn daily_result ->
      {format_date(daily_result.date), daily_result.positive}
    end)
    |> Enum.reverse()
    |> Contex.Dataset.new(["date", "positive"])
  end

  defp format_date(date) do
    {{_year, month, day}, _} = NaiveDateTime.to_erl(date)
    "#{month}/#{day}"
  end
end
