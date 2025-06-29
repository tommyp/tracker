defmodule TrackerWeb.Utils.DateHelpers do
  def humanized!(date) do
    cond do
      Date.compare(date, Date.utc_today()) == :eq ->
        "Today"

      Date.compare(date, Date.utc_today() |> Date.add(1)) == :eq ->
        "Tomorrow"

      Date.compare(date, Date.utc_today() |> Date.add(-1)) == :eq ->
        "Yesterday"

      date ->
        Timex.format!(date, "%e %b %Y", :strftime)
    end
  end
end
