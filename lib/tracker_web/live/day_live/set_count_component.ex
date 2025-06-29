defmodule TrackerWeb.DayLive.SetCountComponent do
  alias Tracker.Goals
  alias Tracker.Goals.GoalEntry
  alias Tracker.Goals
  use TrackerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Set count
      </.header>

      <.simple_form
        for={@form}
        id="goal-entry-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:count]} type="number" label="Count" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{selected_goal_id: goal_id, date: date} = assigns, socket) do
    goal_entry =
      case Goals.get_goal_entry_by_goal_id_and_date(goal_id, date) do
        nil -> %GoalEntry{count: 1}
        goal_entry -> goal_entry
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:goal_entry, goal_entry)
     |> assign_new(:form, fn ->
       to_form(Goals.change_goal_entry_count(goal_entry))
     end)}
  end

  def handle_event("save", %{"goal_entry" => goal_entry_params}, socket) do
    if is_nil(socket.assigns.goal_entry.id) do
      create_goal_entry(socket, goal_entry_params)
    else
      save_goal_entry(socket, socket.assigns.goal_entry, goal_entry_params)
    end
  end

  def handle_event("validate", %{"goal_entry" => goal_entry_params}, socket) do
    changeset = Goals.change_goal_entry_count(socket.assigns.goal_entry, goal_entry_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp save_goal_entry(socket, goal_entry, goal_entry_params) do
    goal = Goals.get_goal!(socket.assigns.selected_goal_id)

    case Goals.update_goal_entry_count(goal_entry, goal_entry_params) do
      {:ok, goal_entry} ->
        notify_parent({:saved_goal_entry, goal_entry})

        {:noreply,
         socket
         |> put_flash(:info, "'#{goal.description}' count updated")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp create_goal_entry(socket, %{"count" => count}) do
    goal = Goals.get_goal!(socket.assigns.selected_goal_id)

    case Goals.create_goal_entry(goal, %{date: socket.assigns.date, count: count}) do
      {:ok, goal_entry} ->
        notify_parent({:saved, goal_entry})

        {:noreply,
         socket
         |> put_flash(:info, "'#{goal.description}' count updated")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
