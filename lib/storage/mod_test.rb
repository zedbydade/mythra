require 'minitest/autorun'
require 'time'
require_relative './memory'
require_relative './mod'

class ModTest < Minitest::Test
  include Mod
  def setup
    path = Pathname.new('./var/test/test.bin')
    FileUtils.mkdir_p(path.dirname)
    File.open(path.to_s, 'wb') do |file|
      file.write nil
    end
    @memory_db = Memory.new(path)
  end

  def test_remove
    @memory_db.atomic_bool.make_true
    @memory_db.call
    ip = '218.121.210.113'
    expire_at = Time.now
    upsert(ip:, expire_at:, memory: @memory_db)
    sleep(0.5)
    remove(ip:, memory: @memory_db)
    @memory_db.atomic_bool.make_true
    sleep(0.5)
    assert_equal({}, @memory_db.read_map)
  end

  def test_double_upsert
    @memory_db.atomic_bool.make_true
    @memory_db.call
    ip = '218.121.210.113'
    expire_at = Time.now
    upsert(ip:, expire_at:, memory: @memory_db)
    sleep(1)
    expire_at2 = Time.now
    ip2 = '217.121.210.113'
    upsert(ip: ip2, expire_at: expire_at2, memory: @memory_db)
    @memory_db.atomic_bool.make_true
    sleep(1)
    assert_equal({ ip => { 'until' => expire_at.to_i, 'times' => 1 }, ip2 => { 'until' => expire_at2.to_i, 'times' => 1 } },
                 @memory_db.read_map)
  end

  def test_iter_active
    @memory_db.atomic_bool.make_true
    @memory_db.call
    ip = '218.121.210.113'
    expire_at = Time.now + 3600
    upsert(ip:, expire_at:, memory: @memory_db)
    sleep(0.5)
    iter_active(memory: @memory_db) do |_, value|
      value['times'] = 100
    end
    @memory_db.atomic_bool.make_true
    sleep(0.5)
    assert_equal({ ip => { 'until' => expire_at.to_i, 'times' => 100 } }, @memory_db.read_map)
  end
end
