require 'pathname'

module Mod
  def get_location(path)
    return path if path.is_a? Pathname

    Pathname.new('/var/lib/mythra/storage.bin')
  end
end
