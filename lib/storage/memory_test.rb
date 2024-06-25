require 'minitest/autorun'
require 'time'
require_relative './memory'

class MemoryTest < Minitest::Test
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
    time = Time.now.to_s
    @memory_db.atomic_bool.make_true
    @memory_db.map = { '31.127.94.124' => { until: time } }
    @memory_db.call
    sleep(1)
    assert_equal({ '31.127.94.124' => { 'until' => time } }, @memory_db.read_map)
    assert_equal false, @memory_db.atomic_bool.true?
    @memory_db.stop
  end

  def test_stop_channel
    @memory_db.map = { '31.127.94.124' => { until: Time.now.to_s } }
    @memory_db.atomic_bool.make_true
    @memory_db.call
    sleep(1)
    entries = @memory_db.stop
    assert_equal false, @memory_db.handler.alive?
    assert_equal 'total entries: 1', entries
  end
end
