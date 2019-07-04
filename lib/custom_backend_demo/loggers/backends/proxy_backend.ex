defmodule CustomBackendDemo.ProxyBackend do
  alias CustomBackendDemo.PhiFilter

  @moduledoc """
  """
  @behaviour :gen_event

  def init({__MODULE__, name}) do
    state =
      :logger
      |> Application.get_env(name)
      |> add_backend_states()

    {:ok, state}
  end

  def handle_call({:configure, _}, %{name: name} = state) do
    state =
      :logger
      |> Application.get_env(name)
      |> init_backend_states(state)

    state =
      Enum.reduce(state.backend_list, state, fn backend, acc ->
        backend_state = state.backend_states[backend.name]
        backend_opts = Application.get_env(:logger, backend.name) || []

        {:ok, :ok, new_state} =
          backend.module.handle_call({:configure, backend_opts}, backend_state)

        put_in(acc, [:backend_states, backend.name], new_state)
      end)

    {:ok, :ok, state}
  end

  def handle_event({level, gl, {Logger, msg, ts, md}}, state) do
    state =
      Enum.reduce(state.backend_list, state, fn backend, acc ->
        backend_state = state.backend_states[backend.name]
        vars = Keyword.get(md, :vars)

        {:ok, new_state} =
          call_backend(backend, vars, {level, gl, {Logger, msg, ts, md}}, backend_state)

        put_in(acc, [:backend_states, backend.name], new_state)
      end)

    {:ok, state}
  end

  def handle_event(_, state), do: {:ok, state}

  def handle_info(key, state) do
    state =
      Enum.reduce(state.backend_list, state, fn backend, acc ->
        backend_state = state.backend_states[backend.name]
        {:ok, new_state} = backend.module.handle_info(key, backend_state)
        put_in(acc, [:backend_states, backend.name], new_state)
      end)

    {:ok, state}
  end

  defp call_backend(
         %{backend_type: :only_phi} = backend,
         vars,
         {level, gl, {Logger, msg, ts, md}},
         backend_state
       ) do
    %{is_phi: is_phi, phi_msg: phi_msg} = PhiFilter.mask(msg, vars)

    if is_phi do
      backend.module.handle_event({level, gl, {Logger, phi_msg, ts, md}}, backend_state)
    else
      {:ok, backend_state}
    end
  end

  defp call_backend(
         %{backend_type: :all_no_phi} = backend,
         vars,
         {level, gl, {Logger, msg, ts, md}},
         backend_state
       ) do
    %{non_phi_msg: non_phi_msg} = PhiFilter.mask(msg, vars)
    backend.module.handle_event({level, gl, {Logger, non_phi_msg, ts, md}}, backend_state)
  end

  defp call_backend(
         %{backend_type: :all} = backend,
         vars,
         {level, gl, {Logger, msg, ts, md}},
         backend_state
       ) do
    %{phi_msg: phi_msg} = PhiFilter.mask(msg, vars)
    backend.module.handle_event({level, gl, {Logger, phi_msg, ts, md}}, backend_state)
  end

  defp call_backend(_, _, _, backend_state), do: {:ok, backend_state}

  defp init_backend_states(env, state) do
    if is_nil(state[:backend_states]) do
      add_backend_states(env)
    else
      state
    end
  end

  defp add_backend_states(env) do
    config = Enum.into(env, %{})

    backend_states =
      config.backend_list
      |> Enum.map(fn backend ->
        _backend_type = backend.backend_type
        module = backend.module
        {:ok, backend_state} = module.init(backend.init_params)
        {backend.name, backend_state}
      end)
      |> Enum.into(%{})

    Map.merge(config, %{backend_states: backend_states})
  end
end
