defmodule TrackerWeb.DayLive.Show do
  alias Tracker.Goals
  alias TrackerWeb.Utils.DateHelpers
  use TrackerWeb, :live_view

  def handle_params(params, _, socket) do
    socket =
      socket
      |> maybe_assign_date(params)
      |> assign_goals()

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <header>
      <div class="flex justify-between md:grid grid-cols-6 uppercase align-baseline">
        <.yesterday_button date={@date} />

        <div class="col-span-4">
          <h1 class="text-center">{DateHelpers.humanized!(@date)}</h1>
        </div>

        <.tomorrow_button date={@date} />
      </div>
    </header>
    <main class="md:grid grid-cols-6">
      <ul class="flex flex-col gap-y-2 col-span-4 col-start-2 md:px-4 py-4 md:py-2">
        <li :for={goal <- @goals} class="px-4 py-2 border border-zinc-300">
          <p class="text-lg">{goal.description}</p>
        </li>
      </ul>
    </main>
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

  defp maybe_assign_date(socket, params) do
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
  end

  defp assign_goals(socket) do
    assign(socket, :goals, Goals.list_goals())
  end
end
