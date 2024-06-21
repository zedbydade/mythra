require 'minitest/autorun'
require_relative './memory'

class TestName < Minitest::Test
  def setup
    path = Pathname.new('./var/test/test.bin')
    FileUtils.mkdir_p(path.dirname)
    File.open(path.to_s, 'wb') do |file|
      file.write nil
    end
    @memory_db = Memory.new(path)
  end

  def test_atomic_bool
    assert_equal true, @memory_db.atomic_bool.false?
  end

  def test_map
    @memory_db.atomic_bool.make_true
    @memory_db.map = { 'hash' => 'value' }
    @memory_db.call
    sleep(0.5)
    assert_equal({ 'hash' => 'value' }, @memory_db.map)
    assert_equal false, @memory_db.atomic_bool.true?
    @memory_db.stop
  end

  def test_stop_channel
    @memory_db.atomic_bool.make_true
    @memory_db.map = 'TU-TU-TEST'
    @memory_db.call
    sleep(0.5)
    entries = @memory_db.stop
    assert_equal false, @memory_db.handler.alive?
    assert_equal 'total entries: 2', entries
  end
end
