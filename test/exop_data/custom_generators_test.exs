defmodule CustomGeneratorsTest do
  use ExUnit.Case, async: true
  use ExopData

  setup do
    {:ok, simple: StreamData.constant(:atom)}
  end

  property "simple", %{simple: generator} do
    contract = [%{name: :a, opts: [type: :atom]}]

    check all params <- generate(contract, generators: %{a: generator}) do
      assert %{a: :atom} == params
    end
  end

  property "Map: with :inner" do
    contract = [
      %{
        name: :a,
        opts: [type: :map, inner: %{b: [type: :atom]}]
      }
    ]

    custom_generator = StreamData.constant(%{b: :atom})

    check all params <- generate(contract, generators: %{a: custom_generator}) do
      assert %{a: %{b: :atom}} = params
    end
  end

  property "List: with :inner" do
    contract = [
      %{
        name: :a,
        opts: [type: :list, inner: %{b: [type: :atom]}]
      }
    ]

    custom_generator = StreamData.constant(b: :atom)

    check all params <- generate(contract, generators: %{a: custom_generator}) do
      assert %{a: [b: :atom]} = params
    end
  end

  property "Map: with nested inner", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [type: :map, inner: %{b: [type: :atom]}]
      }
    ]

    check all params <- generate(contract, generators: %{a: %{b: generator}}) do
      assert %{a: %{b: :atom}} = params
    end
  end

  property "List: with nested inner", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [type: :list, inner: %{b: [type: :atom]}]
      }
    ]

    check all params <- generate(contract, generators: %{a: %{b: generator}}) do
      assert %{a: [b: :atom]} = params
    end
  end

  property "Map: with twice-nested inner", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [
          type: :map,
          inner: %{b: [type: :map, inner: %{c: [type: :atom]}]}
        ]
      }
    ]

    check all params <- generate(contract, generators: %{a: %{b: %{c: generator}}}) do
      assert %{a: %{b: %{c: :atom}}} = params
    end
  end

  property "List: with twice-nested inner", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [
          type: :list,
          inner: %{b: [type: :list, inner: %{c: [type: :atom]}]}
        ]
      }
    ]

    check all params <- generate(contract, generators: %{a: %{b: %{c: generator}}}) do
      assert %{a: [b: [c: :atom]]} = params
    end
  end

  property "List: list_item with one level", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [
          type: :list,
          length: %{is: 2},
          list_item: [type: :atom]
        ]
      }
    ]

    check all %{a: params} <- generate(contract, generators: %{a: [generator]}) do
      assert [:atom, :atom] == params
    end
  end

  property "List: list_item with two levels", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [
          type: :list,
          length: %{is: 1},
          list_item: [type: :list, length: %{is: 1}, list_item: [type: :atom]]
        ]
      }
    ]

    check all %{a: params} <- generate(contract, generators: %{a: [[generator]]}) do
      assert [[:atom]] == params
    end
  end

  property "List: list_item with inner", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [
          type: :list,
          length: %{is: 1},
          list_item: [
            type: :map,
            inner: %{
              key: [type: :atom]
            }
          ]
        ]
      }
    ]

    check all %{a: params} <- generate(contract, generators: %{a: [%{key: generator}]}) do
      assert [%{key: :atom}] = params
    end
  end

  property "List: generator list_item", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [
          type: :list,
          length: %{is: 1},
          list_item: [
            type: :map,
            inner: %{
              key: [type: :atom]
            }
          ]
        ]
      }
    ]

    check all %{a: value} <-
                generate(contract, generators: %{a: StreamData.list_of(generator, length: 1)}) do
      assert [:atom] == value
    end
  end

  property "List: two list_items with inner", %{simple: generator} do
    contract = [
      %{
        name: :a,
        opts: [
          type: :list,
          length: %{is: 1},
          list_item: [
            type: :list,
            length: %{is: 1},
            list_item: [
              type: :map,
              inner: %{
                key: [type: :atom]
              }
            ]
          ]
        ]
      }
    ]

    check all %{a: a} <- generate(contract, generators: %{a: [[%{key: generator}]]}) do
      assert [[%{key: :atom}]] = a
    end
  end

  property "Several inners" do
    contract = [
      %{
        name: :one,
        opts: [
          type: :map,
          inner: %{
            b: [type: :atom],
            c: [type: :map, inner: %{e: [type: :atom]}],
            d: [type: :atom]
          }
        ]
      },
      %{
        name: :two,
        opts: [
          type: :map,
          inner: %{
            b: [type: :atom],
            c: [type: :atom],
            d: [type: :integer, exactly: 1]
          }
        ]
      }
    ]

    b = StreamData.constant(:b)
    d = StreamData.constant(:d)
    e = StreamData.constant(:e)

    check all params <-
                generate(
                  contract,
                  generators: %{one: %{b: b, d: d, c: %{e: e}}, two: %{b: e, c: b}}
                ) do
      assert %{
               one: %{b: :b, c: %{e: :e}, d: :d},
               two: %{b: :e, c: :b, d: 1}
             } == params
    end
  end

  property "with certain value instead of StreamData.constant/1" do
    contract = [
      %{
        name: :a,
        opts: [type: :list, inner: %{b: [type: :atom]}]
      }
    ]

    check all %{a: a} <- generate(contract, generators: %{a: [b: :just_value]}) do
      assert :just_value = a[:b]
    end

    contract = [%{name: :a, opts: [type: :atom]}]

    check all params <- generate(contract, generators: %{a: :another_value}) do
      assert %{a: :another_value} == params
    end
  end

  describe "with sigil syntax" do
    property "certain generator" do
      contract = [
        %{
          name: :a,
          opts: [
            inner: %{
              b: [
                inner: %{
                  c: [type: :integer],
                  e: [
                    inner: %{
                      f: [type: :atom]
                    }
                  ]
                }
              ],
              d: [type: :string]
            }
          ]
        }
      ]

      custom = ~g[
        a: %{
          b: %{
            e: %{
              f: StreamData.binary()
            }
          }
        }
      ]

      check all %{a: a} <- generate(contract, generators: custom) do
        assert is_map(a.b)
        assert is_integer(a.b.c)
        assert is_map(a.b.e)
        assert is_binary(a.b.e.f)
        assert is_binary(a.d)
      end
    end

    property "certain value" do
      contract = [
        %{
          name: :a,
          opts: [
            inner: %{
              b: [
                inner: %{
                  c: [type: :integer],
                  e: [
                    inner: %{
                      f: [type: :atom]
                    }
                  ]
                }
              ],
              d: [type: :string]
            }
          ]
        }
      ]

      custom = ~g[
        a: %{
          b: %{
            e: %{
              f: "qwerty"
            }
          }
        }
      ]

      check all %{a: a} <- generate(contract, generators: custom) do
        assert is_map(a.b)
        assert is_integer(a.b.c)
        assert is_map(a.b.e)
        assert is_binary(a.d)
        assert a.b.e.f == "qwerty"
      end
    end

    property "a few certain values" do
      contract = [
        %{
          name: :a,
          opts: [
            inner: %{
              b: [
                inner: %{
                  c: [type: :integer],
                  e: [
                    inner: %{
                      f: [type: :atom]
                    }
                  ]
                }
              ],
              d: [type: :string]
            }
          ]
        }
      ]

      custom = ~g[
        a: %{
          b: %{
            c: 123,
            e: %{
              f: "qwerty"
            }
          },
          d: "asdfgh"
        }
      ]

      check all %{a: a} <- generate(contract, generators: custom) do
        assert is_map(a.b)
        assert a.b.c == 123
        assert is_map(a.b.e)
        assert a.d == "asdfgh"
        assert a.b.e.f == "qwerty"
      end
    end

    property "mixed" do
      contract = [
        %{
          name: :a,
          opts: [
            inner: %{
              b: [
                inner: %{
                  c: [type: :integer],
                  e: [
                    inner: %{
                      f: [type: :atom]
                    }
                  ]
                }
              ],
              d: [type: :string]
            }
          ]
        }
      ]

      custom = ~g[
        a: %{
          b: %{
            c: 123,
            e: %{
              f: StreamData.binary()
            }
          }
        }
      ]

      check all %{a: a} <- generate(contract, generators: custom) do
        assert is_map(a.b)
        assert a.b.c == 123
        assert is_map(a.b.e)
        assert is_binary(a.d)
        assert is_binary(a.b.e.f)
      end
    end
  end
end
