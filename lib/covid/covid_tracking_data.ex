defmodule Covid.CovidTrackingData do
  @moduledoc """
  Responsible for fetching data from https://covidtracking.com/
  """

  defmodule DailyResult do
    @type t :: %__MODULE__{
            date: NaiveDateTime.t(),
            date_checked: NaiveDateTime.t(),
            death: integer(),
            death_increase: integer(),
            fips: String.t(),
            hash: String.t(),
            hospitalized: integer(),
            hospitalized_increase: integer(),
            negative: integer(),
            negative_increase: integer(),
            pending: integer(),
            positive: integer(),
            positive_increase: integer(),
            state: String.t(),
            total_test_results: integer(),
            total_test_results_increase: integer(),
            raw: map()
          }
    defstruct [
      :date,
      :date_checked,
      :death,
      :death_increase,
      :fips,
      :hash,
      :hospitalized,
      :hospitalized_increase,
      :negative,
      :negative_increase,
      :pending,
      :positive,
      :positive_increase,
      :state,
      :total_test_results,
      :total_test_results_increase,
      :raw
    ]

    def parse(row) do
      %__MODULE__{
        date: parse_date_integer(row["date"]),
        date_checked: parse_date_string(row["dateChecked"]),
        death: row["death"],
        death_increase: row["deathIncrease"],
        fips: row["fips"],
        hash: row["hash"],
        hospitalized: row["hospitalized"],
        hospitalized_increase: row["hospitalizedIncrease"],
        negative: row["negative"],
        negative_increase: row["negativeIncrease"],
        pending: row["pending"],
        positive: row["positive"],
        positive_increase: row["positiveIncrease"],
        state: row["state"],
        total_test_results: row["totalTestResults"],
        total_test_results_increase: row["totalTestResultsIncrease"],
        raw: row
      }
    end

    @doc """
    iex> Covid.CovidTrackingData.DailyResult.parse_date_integer(20200328)
    ~N[2020-03-28 00:00:00]
    """
    def parse_date_integer(date_integer) do
      [y1, y2, y3, y4, m1, m2, d1, d2] = Integer.digits(date_integer)

      date_tuple = {
        {
          Integer.undigits([y1, y2, y3, y4]),
          Integer.undigits([m1, m2]),
          Integer.undigits([d1, d2])
        },
        {0, 0, 0}
      }

      NaiveDateTime.from_erl!(date_tuple)
    end

    # Example:
    # "dateChecked" => "2020-03-28T20:00:00Z",
    def parse_date_string(date_string) do
      NaiveDateTime.from_iso8601(date_string)
    end
  end

  @spec fetch :: [DailyResult.t()]
  def fetch do
    with {:ok, response} <- Mojito.request(:get, api_url()),
         {:ok, json} <- Jason.decode(response.body) do
      {:ok, Enum.map(json, &DailyResult.parse/1)}
    end
  end

  defp api_url, do: "https://covidtracking.com/api/states/daily?state=HI"
end
