class Class
  def cattr_reader(*syms)
    syms.flatten.each do |sym|
      next if sym.is_a?(Hash)
      class_eval("
        unless defined? @@#{sym}\n
          @@#{sym} = nil\n
        end\n
        def self.#{sym}\n
          @@#{sym}\n
        end\n
        def #{sym}\n
          @@#{sym}\n
        end\n", __FILE__, __LINE__)
    end
  end
end