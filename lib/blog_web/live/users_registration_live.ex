defmodule BlogWeb.UsersRegistrationLive do
  use BlogWeb, :live_view

  alias Blog.Accounts
  alias Blog.Accounts.Users

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # Check if registration is enabled and no users exist
    cond do
      not Application.get_env(:blog, :registration_enabled, false) ->
        {:ok,
         socket
         |> put_flash(:error, "Registration is currently disabled")
         |> redirect(to: ~p"/users/log_in")}
      
      Accounts.has_any_users?() ->
        {:ok,
         socket
         |> put_flash(:error, "Registration is closed. Only one user account is allowed.")
         |> redirect(to: ~p"/users/log_in")}
      
      true ->
        changeset = Accounts.change_users_registration(%Users{})

        socket =
          socket
          |> assign(trigger_submit: false, check_errors: false)
          |> assign_form(changeset)

        {:ok, socket, temporary_assigns: [form: nil]}
    end
  end

  def handle_event("save", %{"users" => users_params}, socket) do
    case Accounts.register_users(users_params) do
      {:ok, users} ->
        {:ok, _} =
          Accounts.deliver_users_confirmation_instructions(
            users,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_users_registration(users)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"users" => users_params}, socket) do
    changeset = Accounts.change_users_registration(%Users{}, users_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "users")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
