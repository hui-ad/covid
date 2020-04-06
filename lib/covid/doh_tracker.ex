defmodule Covid.DohTracker do
  use Boundary, deps: [], exports: []

  defdelegate get_main_html_text(page), to: Covid.DohTracker.SiteFetcher
end
