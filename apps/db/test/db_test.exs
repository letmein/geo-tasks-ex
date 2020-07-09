defmodule DbTest do
  use Db.RepoCase

  test ".create_task" do
    {:ok, task} = Db.create_task({0.1, 0.2}, {0.3, 0.4}, "test")

    assert task.lat1 == 0.1
    assert task.long1 == 0.2
    assert task.lat2 == 0.3
    assert task.long2 == 0.4
    assert task.description == "test"
  end

  test ".nearby_tasks" do
    milan = {45.463619, 9.188120}
    genova = {44.4056, 8.9463}
    bologna = {44.4949, 11.3426}
    florence = {43.7696, 11.2558}
    rome = {41.9028, 12.4964}

    {:ok, _} = Db.create_task(genova, bologna, "Genova -> Bologna")
    {:ok, _} = Db.create_task(bologna, genova, "Bologna -> Genova")
    {:ok, _} = Db.create_task(florence, rome, "Florence -> Rome")

    get_result = fn loc ->
      Db.nearby_tasks(loc) |> Enum.map(fn rec -> rec.description end)
    end

    assert ["Genova -> Bologna", "Bologna -> Genova", "Florence -> Rome"] = get_result.(milan)
    assert ["Bologna -> Genova", "Florence -> Rome", "Genova -> Bologna"] = get_result.(bologna)
  end
end
