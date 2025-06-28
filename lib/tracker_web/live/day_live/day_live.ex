defmodule TrackerWeb.DayLive.Show do
  alias TrackerWeb.Utils.DateHelpers
  use TrackerWeb, :live_view

  def handle_params(params, _, socket) do
    socket =
      if Map.has_key?(params, "date") do
        try do
          date = Map.get(params, "date")
          assign(socket, :date, Date.from_iso8601!(date))
        rescue
          ArgumentError ->
            socket
            |> push_patch(to: ~p"/")
        end
      else
        assign(socket, :date, Date.utc_today())
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-6 uppercase">
      <.yesterday_button date={@date} />

      <div class="col-span-4">
        <h1 class="text-center">{DateHelpers.humanized!(@date)}</h1>
      </div>

      <.tomorrow_button date={@date} />
    </div>
    """
  end

  defp yesterday_button(assigns) do
    assigns = assign(assigns, :date, Date.add(assigns.date, -1))

    ~H"""
    <button
      class="flex gap-x-2 p-1 border border-zinc-600 rounded"
      id="yesterday"
      phx-click="date-change"
      phx-value-date={@date}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="size-6"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
      </svg>

      {DateHelpers.humanized!(@date)}
    </button>
    """
  end

  defp tomorrow_button(assigns) do
    assigns = assign(assigns, :date, Date.add(assigns.date, 1))

    ~H"""
    <button
      class="flex justify-end gap-x-2 p-1 border border-zinc-600 rounded"
      id="tomorrow"
      phx-click="date-change"
      phx-value-date={@date}
    >
      {DateHelpers.humanized!(@date)}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="size-6"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" />
      </svg>
    </button>
    """
  end

  def handle_event("date-change", %{"date" => date}, socket) do
    {:noreply,
     socket
     |> assign(:date, date)
     |> push_patch(to: ~p"/?date=#{date}", replace: true)}
  end
end
