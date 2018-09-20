defmodule RavioliCook.JobDividerTest do
  use ExUnit.Case, async: true

  alias RavioliCook.{JobDivider, Job}

  describe "type: list" do
    test "divides input into list of given size" do
      input = (1..10) |> Enum.to_list() |> Poison.encode!()
      job = %Job{input: input, division_type: "list_5", metadata: Poison.encode!("")}

      [t1, t2] = JobDivider.divide_job_into_tasks(job)
      assert [1, 2, 3, 4, 5]  = t1["input"]
      assert [6, 7, 8, 9, 10] = t2["input"]
    end
  end

  describe "type: two_lists" do
    input = [[1,2], [3,4]] |> Poison.encode!()
    job = %Job{input: input, division_type: "two_lists", metadata: Poison.encode!("")}

    assert [
      [1,3], [1,4], [2,3], [2,4],
      [3,1], [3,2], [4,1], [4,2]
    ] =
      job
      |> JobDivider.divide_job_into_tasks()
      |> Enum.map(&(&1["input"]))
  end

  describe "replicate_tasks" do
    test "rate=2.0" do
      tasks = [1,2]

      assert [_, _, _, _] =
        JobDivider.replicate_tasks(tasks, %{replication_rate: 2.0})
    end

    test "rate=2.6" do
      tasks = [1,2]

      assert [_, _, _, _, _] =
        JobDivider.replicate_tasks(tasks, %{replication_rate: 2.6})
    end

    test "rate=1.5" do
      tasks = [1,2,3]

      assert [_, _, _, _, _] =
        JobDivider.replicate_tasks(tasks, %{replication_rate: 1.5})
    end
  end
end
