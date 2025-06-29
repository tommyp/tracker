require Logger

defmodule TrackerWeb.DayLive.Show do
  alias Tracker.Goals.Goal
  alias Tracker.Goals.GoalEntry
  alias Tracker.Goals
  alias TrackerWeb.Utils.DateHelpers
  use TrackerWeb, :live_view

  def handle_params(params, _, socket) do
    socket =
      socket
      |> maybe_assign_date(params)
      |> assign_goals_and_entries()

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <header>
      <h1 class="mb-10 font-bold text-5xl text-center uppercase">Goals</h1>
      <div class="top-4 right-4 absolute flex gap-x-4">
        <.link class="p-1 text-zinc-600 hover:text-zinc-900" href={~p"/goals"}>
          Manage goals
        </.link>
        <.link
          class="flex gap-x-2 bg-white hover:bg-green-500 p-1 border border-green-500 rounded text-green-500 hover:text-white"
          href={~p"/goals/new"}
          id="new-goal"
        >
          New goal
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="size-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M12 9v6m3-3H9m12 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
          </svg>
        </.link>
      </div>

      <div class="flex justify-between md:grid grid-cols-6 uppercase align-baseline">
        <.yesterday_button date={@date} />

        <div class="relative col-span-4">
          <h1 class="p-1 text-center">{DateHelpers.humanized!(@date)}</h1>
        </div>

        <.tomorrow_button date={@date} />
      </div>
    </header>
    <main class="md:grid grid-cols-6">
      <ul class="flex flex-col gap-y-2 col-span-4 col-start-2 md:px-4 py-4 md:py-2">
        <li
          :for={{goal, entry} <- @goals_and_entries}
          class={[
            "flex justify-between px-4 py-2 border border-zinc-300",
            goal_completed?(goal, entry) && "bg-zinc-100 opacity-70"
          ]}
        >
          <p class="text-lg">{goal.description} {entry && entry.count}</p>
          <.actions goal={goal} goal_entry={entry} />
        </li>
      </ul>
    </main>
    """
  end

  defp actions(%{goal: %{type: :boolean}} = assigns) do
    ~H"""
    <div>
      <.button
        phx-click="toggle_complete"
        phx-value-goal-id={@goal.id}
        phx-value-goal-entry-id={maybe_goal_entry_id(@goal_entry)}
        id={"toggle-completed-#{@goal.id}"}
      >
        <svg
          :if={!goal_completed?(@goal_entry)}
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-6"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
        </svg>

        <svg
          :if={goal_completed?(@goal_entry)}
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-6"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
        </svg>
      </.button>
    </div>
    """
  end

  defp actions(%{goal: %{type: :numeric}} = assigns) do
    ~H"""
    <div>
      <.button
        id={"decrement-#{@goal.id}"}
        disabled={is_nil(@goal_entry)}
        phx-click="decrement"
        phx-value-goal-id={@goal.id}
        phx-value-goal-entry-id={maybe_goal_entry_id(@goal_entry)}
      >
        -
      </.button>
      <.button
        id={"increment-#{@goal.id}"}
        phx-click="increment"
        phx-value-goal-id={@goal.id}
        phx-value-goal-entry-id={maybe_goal_entry_id(@goal_entry)}
      >
        +
      </.button>
    </div>
    """
  end

  defp goal_completed?(nil), do: false
  defp goal_completed?(%{completed: status}), do: status

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

  def handle_event(
        "toggle_complete",
        %{"goal-id" => goal_id} = params,
        %{assigns: %{date: date}} = socket
      ) do
    goal = Goals.get_goal!(goal_id)

    goal_entry_id = Map.get(params, "goal-entry-id")

    case goal_entry_id do
      nil ->
        Goals.create_goal_entry(goal, %{completed: true, date: date})

      id ->
        entry = Goals.get_goal_entry!(id)

        Goals.update_goal_entry(entry, %{completed: !entry.completed})
    end

    {:noreply, assign(socket, :goals_and_entries, Goals.list_goals_with_entries_for_date(date))}
  end

  def handle_event(
        "increment",
        %{"goal-id" => goal_id} = params,
        %{assigns: %{date: date}} = socket
      ) do
    goal = Goals.get_goal!(goal_id)

    goal_entry_id = Map.get(params, "goal-entry-id")

    case goal_entry_id do
      nil ->
        Goals.create_goal_entry(goal, %{count: 1, date: date})

      id ->
        entry = Goals.get_goal_entry!(id)

        Goals.increment_goal_entry_count(entry)
    end

    {:noreply, assign(socket, :goals_and_entries, Goals.list_goals_with_entries_for_date(date))}
  end

  def handle_event(
        "decrement",
        %{"goal-id" => goal_id} = params,
        %{assigns: %{date: date}} = socket
      ) do
    goal = Goals.get_goal!(goal_id)

    goal_entry_id = Map.get(params, "goal-entry-id")

    case goal_entry_id do
      nil ->
        Goals.create_goal_entry(goal, %{count: 1, date: date})

      id ->
        entry = Goals.get_goal_entry!(id)

        if entry.count == 1 do
          case Goals.delete_goal_entry(entry) do
            {:ok, _} -> nil
            {:error, error} -> Logger.error(error)
          end
        else
          Goals.decrement_goal_entry_count(entry)
        end
    end

    {:noreply, assign(socket, :goals_and_entries, Goals.list_goals_with_entries_for_date(date))}
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

  defp assign_goals_and_entries(%{assigns: %{date: date}} = socket) do
    assign(socket, :goals_and_entries, Goals.list_goals_with_entries_for_date(date))
  end

  defp maybe_goal_entry_id(nil), do: nil
  defp maybe_goal_entry_id(%GoalEntry{id: id}), do: id

  defp goal_completed?(%Goal{type: :boolean}, %GoalEntry{completed: true}), do: true

  defp goal_completed?(%Goal{type: :numeric, numeric_target: target}, %GoalEntry{count: count})
       when count >= target,
       do: true

  defp goal_completed?(_, _), do: false
end
