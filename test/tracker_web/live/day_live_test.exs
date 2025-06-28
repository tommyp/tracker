defmodule TrackerWeb.DayLiveTest do
  use TrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "visiting the page shows the nav", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "Yesterday"
    assert html =~ "Today"
    assert html =~ "Tomorrow"
  end

  test "clicking on yesterday redirects to yesterday's date", %{conn: conn} do
    yesterday = Date.utc_today() |> Date.add(-1)

    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("button#yesterday")
    |> render_click()

    assert_patch(view, ~p"/?date=#{Date.to_string(yesterday)}")
  end

  test "clicking on tomorrow redirects to tomorrow's date", %{conn: conn} do
    tomorrow = Date.utc_today() |> Date.add(1)

    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("button#tomorrow")
    |> render_click()

    assert_patch(view, ~p"/?date=#{Date.to_string(tomorrow)}")
  end
end
