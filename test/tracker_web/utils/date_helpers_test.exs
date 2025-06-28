defmodule TrackerWeb.Utils.DateHelpersTest do
  use ExUnit.Case, async: true
  alias TrackerWeb.Utils.DateHelpers

  describe "humanized!/1" do
    test "returns 'Today' for today's date" do
      today = Date.utc_today()

      assert DateHelpers.humanized!(today) == "Today"
    end

    test "returns 'Tomorrow' for tomorrow's date" do
      tomorrow = Date.utc_today() |> Date.add(1)

      assert DateHelpers.humanized!(tomorrow) == "Tomorrow"
    end

    test "returns 'Yesterday' for yesterdays's date" do
      yesterday = Date.utc_today() |> Date.add(-1)

      assert DateHelpers.humanized!(yesterday) == "Yesterday"
    end

    test "returns a formatted string for any other date" do
      date = ~D[2025-01-01]

      assert DateHelpers.humanized!(date) == " 1 Jan 2025"
    end
  end
end
