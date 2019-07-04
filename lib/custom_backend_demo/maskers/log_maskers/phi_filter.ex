defmodule CustomBackendDemo.PhiFilter do
  def mask(msg, nil) do
    %{phi_msg: msg, non_phi_msg: msg, is_phi: false}
  end

  def mask(msg, vars) when is_binary(msg) do
    non_phi_msg = Enum.reduce(vars, msg, fn({k,v}, acc) -> 
      masked_str = v
      |> mask_data()
      |> inspect()
      
      String.replace(acc, "{{#{k}}}", masked_str, global: true)
    end)

    phi_msg = Enum.reduce(vars, msg, fn({k,v}, acc) -> 
      input_str = v
      |> inspect()
      
      String.replace(acc, "{{#{k}}}", input_str, global: true)
    end)

    is_phi = non_phi_msg != phi_msg
    %{is_phi: is_phi, non_phi_msg: non_phi_msg, phi_msg: phi_msg}
  end

  def mask(msg, _), do: %{phi_msg: msg, non_phi_msg: msg, is_phi: false}

  def mask_data(data) when is_list(data) do
    Enum.map(data, fn x -> mask_data(x) end)
  end

  def mask_data(data) when is_map(data) do
    data
    |> mask_field("first_name")
    |> mask_field("last_name")
    |> mask_field("username")
    |> mask_field("birthdate")
    |> mask_field("email")
    |> mask_field(:first_name)
    |> mask_field(:last_name)
    |> mask_field(:username)
    |> mask_field(:birthdate)
    |> mask_field(:email)
  end

  def mask_data(_data), do: "***** nice try *****"

  def mask_field(%{} = map, key), do: mask_string(map, key, Map.get(map, key))

  def mask_string(map, _, nil), do: map

  def mask_string(map, key, value) do
    mask_length =
      value
      |> to_string()
      |> String.length()

    masked_str = String.duplicate("*", mask_length)
    Map.put(map, key, masked_str)
  end
end