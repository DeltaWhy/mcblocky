require 'test_helper'

class NBTJSONTest < Minitest::Test
  def test_setblock_encodes_nbt
    # top level
    commands = assert_valid do
      setblock 1, 2, 3, 'minecraft:command_block', 0, :replace, {'Command'=>'say Hello'}
    end
    assert_includes commands[1], '{Command:"say Hello"}'

    # in initial block
    commands = assert_valid do
      initial do
        setblock 1, 2, 3, 'minecraft:command_block', 0, :replace, {'Command'=>'say Hello'}
      end
    end
    assert_includes commands[0], '{Command:"say Hello"}'
  end

  def test_blockdata_encodes_nbt
    commands = assert_valid do
      initial do
        blockdata 1, 2, 3, {'Command'=>'say Hello'}
      end
    end
    assert_equal ['blockdata 1 2 3 {Command:"say Hello"}'], commands
  end

  def test_replaceitem_encodes_nbt
    commands = assert_valid do
      initial do
        replaceitem :entity, @a[team: 'Blue'], 'slot.armor.chest', 'minecraft:leather_chestplate', 1, 0, {display:{color:3361970}}
      end
    end
    assert_equal [
      'replaceitem entity @a[team=Blue] slot.armor.chest minecraft:leather_chestplate 1 0 {display:{color:3361970}}'
    ], commands
  end

  def test_tellraw_encodes_json
    commands = assert_valid do
      initial do
        tellraw @a, {text: 'Hello'}, {text: 'World'}
      end
    end
    assert_equal ['tellraw @a [{"text":"Hello"},{"text":"World"}]'], commands

    commands = assert_valid do
      initial do
        tellraw @a, [{text: 'Hello'}, {text: 'World'}]
      end
    end
    assert_equal ['tellraw @a [{"text":"Hello"},{"text":"World"}]'], commands
  end

  def test_title_encodes_json
    commands = assert_valid do
      initial do
        title @a, :title, {text: "Score", color: "red"}
      end
    end
    assert_equal ['title @a title [{"text":"Score","color":"red"}]'], commands
  end

  def test_nested_nbt
    assert_equal '{tag:{display:{Name:"Bob"}}}', McBlocky::DSL.to_nbt(
      {tag: {display: {'Name'=>'Bob'}}}
    )
    assert_equal '[{slot:0,id:"minecraft:diamond"},{slot:1,id:"minecraft:iron_ingot"}]',
      McBlocky::DSL.to_nbt([
        {slot: 0, id: 'minecraft:diamond'},
        {slot: 1, id: 'minecraft:iron_ingot'}
      ])
  end

  def test_to_json
    assert_equal '"Hello"', McBlocky::DSL.to_json("Hello")
    assert_equal '42', McBlocky::DSL.to_json(42)
    assert_equal '{"foo":"bar"}', McBlocky::DSL.to_json({foo: 'bar'})
    assert_equal '[42]', McBlocky::DSL.to_json([42])
    assert_equal '[1,2,"foo"]', McBlocky::DSL.to_json(1, 2, "foo")
  end
end
