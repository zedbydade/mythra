require 'concurrent-edge'
require 'zlib'
require 'msgpack'
require_relative 'mod'

class Memory
  attr_accessor :path, :atomic_bool, :handler, :stop_channel
  attr_writer :map

  include Mod

  def initialize(path)
    @path = path
    @map = read_map
    @atomic_bool = Concurrent::AtomicBoolean.new(false)
    @handler = nil
    @stop_channel = nil
  end

  def call
    @stop_channel = Concurrent::Channel.new
    ticker = Concurrent::Channel.ticker(0.5)
    @handler = Thread.new do
      loop do
        Concurrent::Channel.select do |s|
          s.take(ticker) do
            save(@path, @map) if @atomic_bool.true?
            @atomic_bool.make_false
          end
          s.take(@stop_channel) { @handler.kill }
        end
      end
    end
  end

  def stop
    @stop_channel.put 'STOP'

    p 'storage shut down'
    p 'storage statics:'
    p 'total entries: 2'
  end

  def read_map
    msg = File.binread(get_location(path))
    MessagePack.unpack(msg)
  rescue EOFError
    {}
  end

  private

  def save(location, map)
    msg = MessagePack.pack(map)
    File.open(location, 'wb') do |file|
      file.write msg
    end
  end
end
