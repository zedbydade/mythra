require 'pathname'
require_relative 'memory'

module Mod
  def upsert(ip:, expire_at:, memory:)
    map = memory.read_map

    map[ip] = if map[ip]
                map[ip]['until'] = expire_at.to_i
                map[ip]['times'] += 1
                map[ip]
              else
                map[ip] = { 'until' => expire_at.to_i, times: 1 }
              end
    memory.map = map
  end

  def remove(ip:, memory:)
    map = memory.read_map
    map.delete(ip)
    memory.map = map
  end

  def iter_active(memory:, &block)
    map = memory.read_map.select do |_, hash|
      hash['until'] > Time.now.to_i
    end
    map.each(&block)
    memory.map = map
  end

  def iter_outdated(memory:, &block)
    map = memory.read_map.select do |_, hash|
      hash['until'] < Time.now.to_i
    end
    map.each(&block)
    memory.map = map
  end

  def get_location(path)
    return path if path.is_a? Pathname

    Pathname.new('./var/lib/mythra/mythra.bin')
  end
end
