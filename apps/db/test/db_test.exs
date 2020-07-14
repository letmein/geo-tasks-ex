defmodule DbTest do
  use Db.RepoCase

  describe ".authorized?" do
    test "return true for valid user_id, token and role combination" do
      {:ok, %{id: token_id, token: token}} = Db.create_token(Db.role_manager)
      {:ok, %{id: user_id}} = Db.create_user(token_id)

      assert Db.authorized?(user_id, token, Db.role_manager)
    end

    test "return false for valid user_id, token and role combination" do
      {:ok, %{id: token_id, token: token}} = Db.create_token(Db.role_manager)
      {:ok, %{id: user_id}} = Db.create_user(token_id)

      refute Db.authorized?(user_id, token, Db.role_driver)
      refute Db.authorized?("123", token, Db.role_manager)
      refute Db.authorized?(user_id, "foo", Db.role_manager)
    end
  end

  describe ".create_task" do
    test "success" do
      {:ok, task} = Db.create_task({0.1, 0.2}, {0.3, 0.4}, "test")

      assert task.lat1 == 0.1
      assert task.long1 == 0.2
      assert task.lat2 == 0.3
      assert task.long2 == 0.4
      assert task.description == "test"
      assert task.status == "new"
    end

    test "invalid payload" do
      assert {:error, %{long1: _}} = Db.create_task({0.1, nil}, {0.3, 0.4}, "test")
    end
  end

  describe ".nearby_tasks" do
    test "return tasks sorted by distance" do
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
end
