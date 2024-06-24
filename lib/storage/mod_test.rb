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

  def test_double_upsert
    @memory_db.atomic_bool.make_true
    @memory_db.call
    ip = '218.121.210.113'
    expire_at = Time.now.to_s
    upsert(ip:, expire_at:, memory: @memory_db)
    sleep(1)
    expire_at2 = Time.now.to_s
    ip2 = '217.121.210.113'
    upsert(ip: ip2, expire_at: expire_at2, memory: @memory_db)
    @memory_db.atomic_bool.make_true
    sleep(1)
    assert_equal({ ip => { 'until' => expire_at, 'times' => 1 }, ip2 => { 'until' => expire_at2, 'times' => 1 } },
                 @memory_db.read_map)
  end
end
