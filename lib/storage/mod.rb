require 'pathname'
require_relative 'memory'

module Mod
  def upsert(ip:, expire_until:, memory:)
    map = memory.read_map

    memory.map = if map[ip]
                   map[ip]['until'] = expire_until
                 else
                   map[ip] = { 'until' => expire_until, times: 0 }
                 end
  end

  def get_location(path)
    return path if path.is_a? Pathname

    Pathname.new('./var/lib/mythra/mythra.bin')
  end
end
