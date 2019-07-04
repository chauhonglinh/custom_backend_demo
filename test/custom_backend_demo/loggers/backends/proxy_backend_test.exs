defmodule CustomBackendDemo.ProxyBackendTest do
  alias CustomBackendDemo.ProxyBackend
  use ExUnit.Case

  require Logger

  @phi_patient %{
    first_name: "John",
    last_name: "Smith",
    birthdate: "1980-01-01",
    email: "test@email.com"
  }

  @time_stamp {{2019, 6, 24}, {15, 8, 8, 998}}
  @metadata [vars: %{patient: @phi_patient}]
  @level :warn
  @gl {0, 250, 0}
  @msg "Here is a patient: {{patient}}."

  @only_phi_log "tmp/only_phi.log"
  @all_no_phi_log "tmp/all_no_phi.log"
  @all_log "tmp/all.log"

  describe "init/2" do
    test "creates a list of backend states correctly" do
      {:ok, state} = ProxyBackend.init({ProxyBackend, :proxy_log})

      assert state == %{
               backend_list: [
                 %{
                   backend_type: :only_phi,
                   init_params: {LoggerFileBackend, :only_phi_log},
                   module: LoggerFileBackend,
                   name: :only_phi_log
                 },
                 %{
                   backend_type: :all_no_phi,
                   init_params: {LoggerFileBackend, :all_no_phi_log},
                   module: LoggerFileBackend,
                   name: :all_no_phi_log
                 },
                 %{
                   backend_type: :all,
                   init_params: {LoggerFileBackend, :all_log},
                   module: LoggerFileBackend,
                   name: :all_log
                 }
               ],
               backend_states: %{
                 all_log: %{
                   format: [:time, " ", :metadata, "[", :level, "] ", :message, "\n"],
                   inode: nil,
                   io_device: nil,
                   level: :debug,
                   metadata: [],
                   metadata_filter: nil,
                   name: :all_log,
                   path: "./tmp/all.log",
                   rotate: nil
                 },
                 all_no_phi_log: %{
                   format: [:time, " ", :metadata, "[", :level, "] ", :message, "\n"],
                   inode: nil,
                   io_device: nil,
                   level: :debug,
                   metadata: [],
                   metadata_filter: nil,
                   name: :all_no_phi_log,
                   path: "./tmp/all_no_phi.log",
                   rotate: nil
                 },
                 only_phi_log: %{
                   format: [:time, " ", :metadata, "[", :level, "] ", :message, "\n"],
                   inode: nil,
                   io_device: nil,
                   level: :debug,
                   metadata: [],
                   metadata_filter: nil,
                   name: :only_phi_log,
                   path: "./tmp/only_phi.log",
                   rotate: nil
                 }
               }
             }
    end
  end

  describe "handle_event/2" do
    defp remove_all_logs() do
      File.rm(@all_no_phi_log)
      File.rm(@only_phi_log)
      File.rm(@all_log)
    end

    setup do
      remove_all_logs()
      File.touch(@only_phi_log)

      {:ok, state} = ProxyBackend.init({ProxyBackend, :proxy_log})

      on_exit(fn -> remove_all_logs() end)

      %{state: state}
    end

    test "sends phi information in vars to all backends", %{state: state} do
      ProxyBackend.handle_event({@level, @gl, {Logger, @msg, @time_stamp, @metadata}}, state)

      {:ok, expected_non_phi} = File.read(@all_no_phi_log)

      assert expected_non_phi ==
               ~s(15:08:08.998 [warn] Here is a patient: %{birthdate: "**********", email: "**************", first_name: "****", last_name: "*****"}.\n)

      {:ok, expected_phi} = File.read(@only_phi_log)

      assert expected_phi ==
               ~s(15:08:08.998 [warn] Here is a patient: %{birthdate: "1980-01-01", email: "test@email.com", first_name: "John", last_name: "Smith"}.\n)

      {:ok, expected_all} = File.read(@all_log)

      assert expected_all ==
               ~s(15:08:08.998 [warn] Here is a patient: %{birthdate: "1980-01-01", email: "test@email.com", first_name: "John", last_name: "Smith"}.\n)
    end

    test "sends non-phi information only to all-non-phi-backend and all-backend", %{state: state} do
      ProxyBackend.handle_event({@level, @gl, {Logger, "Hello!", @time_stamp, []}}, state)

      {:ok, expected_non_phi} = File.read(@all_no_phi_log)
      assert expected_non_phi == "15:08:08.998 [warn] Hello!\n"

      {:ok, expected_phi} = File.read(@only_phi_log)
      assert expected_phi == ""

      {:ok, expected_all} = File.read(@all_log)
      assert expected_all == "15:08:08.998 [warn] Hello!\n"
    end

    test "sends error correctly to all-non-phi-backend and all-backend", %{state: state} do
      ProxyBackend.handle_event(
        {@level, @gl, {Logger, "Wrong metadata {{patient}}", @time_stamp, ["Wrong format"]}},
        state
      )

      {:ok, expected_non_phi} = File.read(@all_no_phi_log)

      assert expected_non_phi ==
               "15:08:08.998 [warn] Wrong metadata {{patient}}\n"

      {:ok, expected_phi} = File.read(@only_phi_log)
      assert expected_phi == ""

      {:ok, expected_all} = File.read(@all_log)

      assert expected_all == "15:08:08.998 [warn] Wrong metadata {{patient}}\n"
    end
  end
end
