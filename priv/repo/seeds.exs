# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tracker.Repo.insert!(%Tracker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Tracker.Repo
alias Tracker.Goals.Goal
alias Tracker.Goals.GoalEntry

walk =
  Repo.insert!(%Goal{
    type: :boolean,
    description: "Go for a walk"
  })

:timer.sleep(1)

read =
  Repo.insert!(%Goal{
    type: :numeric,
    numeric_target: 20,
    description: "Read at least 20 pages"
  })

:timer.sleep(1)

medication =
  Repo.insert!(%Goal{
    type: :boolean,
    description: "Take medication"
  })

:timer.sleep(1)

pushups =
  Repo.insert!(%Goal{
    type: :numeric,
    numeric_target: 15,
    description: "Do 15 pushups"
  })

today = Date.utc_today()

0..14
|> Enum.to_list()
|> Enum.map(fn idx ->
  count = 14 - idx

  Repo.insert!(%GoalEntry{
    goal_id: walk.id,
    completed: rem(count, 2) == 0 || count > 10,
    date: Date.add(today, -idx)
  })

  Repo.insert!(%GoalEntry{
    goal_id: read.id,
    count: count * 2,
    date: Date.add(today, -idx)
  })

  Repo.insert!(%GoalEntry{
    goal_id: medication.id,
    completed: idx < 4,
    date: Date.add(today, -idx)
  })

  Repo.insert!(%GoalEntry{
    goal_id: pushups.id,
    count: count,
    date: Date.add(today, -idx)
  })
end)
