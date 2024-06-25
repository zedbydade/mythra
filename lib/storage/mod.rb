require 'pathname'
require_relative 'memory'

module Mod
  def upsert(ip:, expire_at:, memory:)
    map = memory.read_map

    map[ip] = if map[ip]
                map[ip]['until'] = expire_at
                map[ip]['times'] += 1
                map[ip]
              else
                map[ip] = { 'until' => expire_at, times: 1 }
              end
    memory.map = map
  end

  def remove(ip:, memory:)
    map = memory.read_map
    map.delete(ip)
    memory.map = map
  end

  def get_location(path)
    return path if path.is_a? Pathname

    Pathname.new('./var/lib/mythra/mythra.bin')
  end
end
