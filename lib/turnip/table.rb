module Turnip
  class HashWithIndifferentAccess < Hash
    def initialize hash = Hash.new
      super

      hash.each do |k,v|
        self[k] = v
      end

      self.default_proc = Proc.new{|h,k|
        if k.is_a?(String) && h.has_key?(k.to_sym)
          h[k.to_sym]
        elsif k.is_a?(Symbol) && h.has_key?(k.to_s)
          h[k.to_s]
        end
      }
    end
  end
  
  class Table
    attr_reader :raw
    alias_method :to_a, :raw

    include Enumerable

    def initialize(raw)
      @raw = raw
    end

    def headers
      raw.first
    end

    def rows
      raw.drop(1)
    end

    def hashes
      rows.map { |row| HashWithIndifferentAccess.new(Hash[headers.zip(row)]) }
    end

    def rows_hash
      raise WidthMismatch.new(2, width) unless width == 2
      transpose.hashes.first
    end

    def transpose
      self.class.new(raw.transpose)
    end

    def each
      raw.each { |row| yield(row) }
    end

    private

    def width
      raw[0].size
    end

    class WidthMismatch < StandardError
      def initialize(expected, actual)
        super("Expected the table to be #{expected} columns wide, got #{actual}")
      end
    end
  end
end
