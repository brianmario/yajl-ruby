require File.expand_path("../setup", __FILE__)

class DumpLoadAPITest < Minitest::Test
  JSON_STR = "{\"a\":1234}".freeze
  OBJ      = {"a" => 1234}

  def test_dump_class_method_exists
    assert Yajl.respond_to?(:dump)
  end

  def test_dump_class_method_serializes_to_string
    assert_equal JSON_STR, Yajl.dump(OBJ)
  end

  def test_encode_to_an_io
    io = StringIO.new

    Yajl.dump(OBJ, io)

    io.rewind

    assert_equal JSON_STR, io.read
  end

  def test_encode_with_block_supplied
    Yajl.dump(a: 1234) do |chunk|
      assert_equal JSON_STR, chunk
    end
  end

  def test_load_class_method_exists
    assert Yajl.respond_to?(:load)
  end

  def test_parse_from_a_string
    assert_equal OBJ, Yajl.load(JSON_STR)
  end

  def test_parse_from_an_io
    io = StringIO.new(JSON_STR)

    assert_equal OBJ, Yajl.load(io)
  end

  def test_parse_with_block_specified
    Yajl.load(JSON_STR) do |obj|
      assert_equal OBJ, obj
    end
  end

  def test_parse_from_io_with_block_specified
    io = StringIO.new(JSON_STR)

    Yajl.load(io) do |obj|
      assert_equal OBJ, obj
    end
  end
end
