defmodule TrackerWeb.Utils.DateHelpers do
  def humanized!(date) do
    cond do
      date == Date.utc_today() ->
        "Today"

      date == Date.utc_today() |> Date.add(1) ->
        "Tomorrow"

      date == Date.utc_today() |> Date.add(-1) ->
        "Yesterday"

      date ->
        Timex.format!(date, "%e %b %Y", :strftime)
    end
  end
end
