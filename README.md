# Covid

## Data

### Covid Tracking
https://covidtracking.com/
Daily api call: https://covidtracking.com/api/states/daily?state=HI

Has total test results

Sample data:
```
date	20200328
state	"HI"
positive	120
negative	4357
pending	3
hospitalized	8
death	0
total	4480
hash	"89688658eb0c2ae49b9d4f3e1fbd2475ba645063"
dateChecked	"2020-03-28T20:00:00Z"
totalTestResults	4477
fips	"15"
deathIncrease	0
hospitalizedIncrease	1
negativeIncrease	0
positiveIncrease	14
totalTestResultsIncrease	14
```

### Testing data collected from Ryan Ozawa:
https://bit.ly/hawaiicovid19counts

Has spotty data collected locally for 3/21-3/28

### Official Hawaii Website

* https://health.hawaii.gov/coronavirusdisease2019/
* https://health.hawaii.gov/coronavirusdisease2019/what-you-should-know/current-situation-in-hawaii/

### New York Times (cases and deaths only)
Data used in article https://www.nytimes.com/interactive/2020/03/26/us/coronavirus-testing-states.html

Data on cumulative coronavirus cases and deaths can be found in two files for states and counties.
- https://github.com/nytimes/covid-19-data/blob/master/us-states.csv
- https://github.com/nytimes/covid-19-data/blob/master/us-counties.csv



# Setup

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
