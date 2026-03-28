require 'ekylibre-natuition/engine'

module EkylibreNatuition
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
