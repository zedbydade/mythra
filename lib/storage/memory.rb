require 'concurrent-edge'
require_relative 'mod'

class Memory
  attr_accessor :map, :dirty

  def initialize(map, dirty)
    @map = map
    @dirty = dirty
  end

  def self.call(path)
    map = Zlib::GzipReader.open(get_location(path)).read
    atomic_bool = Concurrent::AtomicBoolean(false)
    channel = Concurrent::Channel.new
    ticket = Concurrent::Channel.ticket(0.5)
  end

  private

  def dirty?(atomic_bool)
    atomic_bool.false?
  end
end
