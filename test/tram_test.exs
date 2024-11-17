defmodule TramTest do
  use ExUnit.Case
  doctest Tram

  setup do
    {:ok, pid} = Tram.start_link()
    %{pid: pid}
  end

  test "дефолт" do
    assert Tram.get_state() == :idle

    Tram.transition(:power_on)
    assert Tram.get_state() == :ready

    Tram.transition(:move)
    assert Tram.get_state() == :moving

    Tram.transition(:stop)
    assert Tram.get_state() == :ready

    Tram.transition(:open_doors)
    assert Tram.get_state() == :open

    Tram.transition(:close_doors, %{passengers_entered: 5})
    assert Tram.get_state() == :ready

    Tram.transition(:move)
    assert Tram.get_state() == :moving

    Tram.transition(:stop)
    assert Tram.get_state() == :ready

    Tram.transition(:open_doors)
    assert Tram.get_state() == :open

    Tram.transition(:close_doors, %{passengers_exited: 5})
    assert Tram.get_state() == :ready

    Tram.transition(:power_off)
    assert Tram.get_state() == :final_state
  end

  test "Забыл пассажиров. не может закончить работу" do
    Tram.transition(:power_on)
    Tram.transition(:move)
    Tram.transition(:stop)
    Tram.transition(:open_doors)
    Tram.transition(:close_doors, %{passengers_entered: 5})

    assert {:error, :invalid_transition} == Tram.transition(:power_off)
    assert Tram.get_state() == :ready
  end

  test "некорректный переход не меняет состояние" do
    assert {:error, :invalid_transition} == Tram.transition(:lol)
    assert Tram.get_state() == :idle
  end

  test "пустой" do
    Tram.transition(:power_on)
    Tram.transition(:open_doors)
    Tram.transition(:close_doors)
    assert Tram.get_state() == :ready
  end
end
