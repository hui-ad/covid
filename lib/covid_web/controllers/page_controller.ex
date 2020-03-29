defmodule CovidWeb.PageController do
  use CovidWeb, :controller

  def index(conn, _params) do
    {:ok, data} = Covid.CovidDataStore.get()
    dataset = to_contex_data(data)

    positives_svg = positives_svg(dataset)
    tests_svg = tests_svg(dataset)
    render(conn, "index.html", positives_svg: positives_svg, tests_svg: tests_svg)
  end

  def positives_svg(dataset) do
    plot_content =
      Contex.BarChart.new(dataset)
      |> Contex.BarChart.set_val_col_names(["Positive Tests"])
      |> Contex.BarChart.colours(CovidWeb.BarchartHelpers.lookup_colours("themed"))

    plot =
      Contex.Plot.new(500, 300, plot_content)
      |> Contex.Plot.axis_labels("", "Tests")
      |> Contex.Plot.titles("Positive COVID Tests", nil)
      |> Contex.Plot.plot_options(%{legend_setting: :legend_right})

    Contex.Plot.to_svg(plot)
  end

  def tests_svg(dataset) do
    plot_content =
      Contex.BarChart.new(dataset)
      |> Contex.BarChart.set_val_col_names(["Positive Tests", "Negative Tests"])
      |> Contex.BarChart.colours(CovidWeb.BarchartHelpers.lookup_colours("themed"))

    plot =
      Contex.Plot.new(500, 300, plot_content)
      |> Contex.Plot.axis_labels("", "Tests")
      |> Contex.Plot.titles("Total COVID Tests", nil)
      |> Contex.Plot.plot_options(%{legend_setting: :legend_right})

    Contex.Plot.to_svg(plot)
  end

  def to_contex_data(data) do
    Enum.map(data, fn daily_result ->
      {format_date(daily_result.date), daily_result.positive, daily_result.negative}
    end)
    |> Enum.reverse()
    |> Contex.Dataset.new(["date", "Positive Tests", "Negative Tests"])
  end

  defp format_date(date) do
    {{_year, month, day}, _} = NaiveDateTime.to_erl(date)
    "#{month}/#{day}"
  end
end
