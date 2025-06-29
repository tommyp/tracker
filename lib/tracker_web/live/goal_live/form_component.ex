defmodule TrackerWeb.GoalLive.FormComponent do
  alias Tracker.Goals.Goal
  use TrackerWeb, :live_component

  alias Tracker.Goals

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage goal records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="goal-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:description]} type="text" label="Description" />
        <.input type="select" field={@form[:type]} label="Type" options={@type_options} />
        <.input
          :if={Ecto.Changeset.get_field(@form.source, :type) == :numeric}
          field={@form[:numeric_target]}
          type="number"
          label="Numeric goal"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Goal</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{goal: goal} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_type_options()
     |> assign_new(:form, fn ->
       to_form(Goals.change_goal(goal))
     end)}
  end

  @impl true
  def handle_event("validate", %{"goal" => goal_params}, socket) do
    changeset = Goals.change_goal(socket.assigns.goal, goal_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"goal" => goal_params}, socket) do
    save_goal(socket, socket.assigns.action, goal_params)
  end

  defp save_goal(socket, :edit, goal_params) do
    case Goals.update_goal(socket.assigns.goal, goal_params) do
      {:ok, goal} ->
        notify_parent({:saved, goal})

        {:noreply,
         socket
         |> put_flash(:info, "Goal updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_goal(socket, :new, goal_params) do
    case Goals.create_goal(goal_params) do
      {:ok, goal} ->
        notify_parent({:saved, goal})

        {:noreply,
         socket
         |> put_flash(:info, "Goal created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_type_options(socket) do
    assign(
      socket,
      :type_options,
      Goal
      |> Ecto.Enum.values(:type)
      |> Enum.map(fn type ->
        {String.capitalize(to_string(type)), type}
      end)
    )
  end
end
