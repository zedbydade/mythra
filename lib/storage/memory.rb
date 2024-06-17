require 'concurrent-edge'
require 'zlib'
require_relative 'mod'

class Memory
  attr_accessor :map, :path, :atomic_bool, :handler, :stop_channel

  include Mod

  def initialize(path)
    @path = path
    @map = Zlib::GzipReader.open(get_location(path)).read
    @atomic_bool = Concurrent::AtomicBoolean.new(false)
    @handler = nil
    @stop_channel = nil
  end

  def call
    @stop_channel = Concurrent::Channel.new
    ticker = Concurrent::Channel.ticker(0.5)
    @handler = Thread.new do
      # rubocop:disable Lint/UnreachableLoop
      loop do
        Concurrent::Channel.select do |s|
          s.take(ticker) do
            save(@path, @map) if @atomic_bool.true?
            @atomic_bool.make_false
          end
          s.take(@stop_channel) { break }
        end
      end
      # rubocop:enable Lint/UnreachableLoop
    end
  end

  private

  def save(location, map)
    Zlib::GzipWriter.open(location) do |gz|
      gz.write map
    end
  end
end
