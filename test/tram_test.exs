defmodule TramTest do
  use ExUnit.Case
  doctest Tram

  test "greets the world" do
    assert Tram.hello() == :world
  end
end
