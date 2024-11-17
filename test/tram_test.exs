defmodule TramTest do
  use ExUnit.Case
  doctest Tram

  setup do
    {:ok, pid} = Tram.start_link()
    %{pid: pid}
  end

  test "дефолт" do
    assert Tram.get_state().current == :idle

    Tram.transition(:power_on)
    assert Tram.get_state().current == :ready

    Tram.transition(:move)
    assert Tram.get_state().current == :moving

    Tram.transition(:stop)
    assert Tram.get_state().current == :ready

    Tram.transition(:open_doors)
    assert Tram.get_state().current == :open

    Tram.transition(:close_doors, %{passengers_entered: 5})
    assert Tram.get_state() == %Tram{current: :ready, data: %{passengers: 5}}

    Tram.transition(:move)
    assert Tram.get_state().current == :moving

    Tram.transition(:stop)
    assert Tram.get_state().current == :ready

    Tram.transition(:open_doors)
    assert Tram.get_state().current == :open

    Tram.transition(:close_doors, %{passengers_exited: 5})
    assert Tram.get_state() == %Tram{current: :ready, data: %{passengers: 0}}

    Tram.transition(:power_off)
    assert Tram.get_state().current == :final_state
  end

  test "Забыл высадить пассажиров. не может закончить работу" do
    Tram.transition(:power_on)
    Tram.transition(:move)
    Tram.transition(:stop)
    Tram.transition(:open_doors)
    Tram.transition(:close_doors, %{passengers_entered: 5})

    assert {:error, :invalid_transition} == Tram.transition(:power_off)
    assert Tram.get_state().current == :ready
  end

  test "пустой" do
    Tram.transition(:power_on)
    Tram.transition(:open_doors)
    Tram.transition(:close_doors)
    assert Tram.get_state().current == :ready
  end

  test "несуществующий переход из ready не меняет состояние" do
    Tram.transition(:power_on)
    Tram.transition(:close_doors)
    Tram.transition(:stop)
    assert Tram.get_state().current == :ready
  end

  test "несуществующий переход не меняет состояние" do
    Tram.transition(:power_on)
    assert {:error, :invalid_transition} == Tram.transition(:lol)
    assert Tram.get_state().current == :ready
  end
end
