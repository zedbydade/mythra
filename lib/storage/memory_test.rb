require 'minitest/autorun'
require_relative './memory'

class TestName < Minitest::Test
  def setup
    path = Pathname.new('./var/test/test.bin')
    FileUtils.mkdir_p(path.dirname)
    Zlib::GzipWriter.open(path.to_s) {}
    @memory_db = Memory.new(path)
  end

  def test_atomic_bool
    assert_equal true, @memory_db.atomic_bool.false?
  end

  def test_map
    @memory_db.atomic_bool.make_true
    @memory_db.map = 'TU-TU-TEST'
    @memory_db.call
    assert_equal 'TU-TU-TEST', @memory_db.map
    assert_equal true, @memory_db.atomic_bool.true?
  end

  def test_stop_channel
    @memory_db.call
    @memory_db.stop_channel.put 'STOP'
    assert_equal false, @memory_db.handler.alive?
  end
end
