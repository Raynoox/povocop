defmodule RavioliShop.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use RavioliShop.Web, :controller
      use RavioliShop.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def schema do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      import Ecto
      import Ecto.Query

      import RavioliShop.Router.Helpers
      import RavioliShop.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [
        get_csrf_token: 0,
         get_flash: 2,
          view_module: 1
      ]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import RavioliShop.Router.Helpers
      import RavioliShop.ErrorHelpers
      import RavioliShop.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias RavioliShop.Repo
      import Ecto
      import Ecto.Query
      import RavioliShop.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end