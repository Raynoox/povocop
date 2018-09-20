defmodule RavioliShop.Repo.Migrations.PointSystem do
  use Ecto.Migration

  def change do
    create table(:user_job_points, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :job_id, references(:jobs, on_delete: :delete_all, type: :uuid)
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      add :pfc_sum, :integer
      add :pfc_count, :integer

      timestamps()
    end

    create unique_index(:user_job_points, [:job_id, :user_id])
    
    alter table(:jobs) do
      add :pfc_sum, :integer
      add :pfc_count, :integer
    end

    alter table(:users) do
      add :points, :integer, default: 0
    end
  end
end
