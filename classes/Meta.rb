class Integer
  def self._(arg)
    @val ||= 1
    
    @val *= arg
  end
  
  { 
    second: _(1),  minute: _(60), hour: _(60),
    day: _(24),  week: _(7), month: _(4), year: _(12) 
  }.each { |method, mult|
      plural = (method.to_s.concat("s")).to_sym
      
      define_method method do 
        self * mult
      end
      
      alias_method plural, method
    }
  @val = 1.0
  {
    #[ :yb , :yoctobyte ]  =>  _(  1024**3 ), 
    #[ :zb , :zeptobyte ]  =>  _(  1024**3 ),
    #[ :ab , :attobyte  ]  =>  _(  1024**3 ),
    #[ :fb , :femtobyte ]  =>  _(  1024**3 ),
    #[ :pb , :picobyte  ]  =>  _(  1024**3 ),
    #[ :nb , :nanobyte  ]  =>  _(  1024**3 ),
    #[ :ub , :microbyte ]  =>  _(  1024**3 ),
    #[ :mb , :milibyte  ]  =>  _(  1024**3 ),
    [ :b  , :byte      ]  =>  _(     1    ),
    [ :kb , :kilobyte  ]  =>  _(   1024   ),
    [ :Mb , :megabyte  ]  =>  _(   1024   ),
    [ :Gb , :gigabyte  ]  =>  _(   1024   ),
    [ :Tb , :terabyte  ]  =>  _(   1024   ),
    [ :Pb , :petabyte  ]  =>  _(   1024   ),
    [ :Eb , :exabyte   ]  =>  _(   1024   ),
    [ :Zb , :zettabyte ]  =>  _(   1024   ),
    [ :Yb , :yottabyte ]  =>  _(   1024   )
  }.each { |methods, mult|
    short, long = methods
    plural = (long.to_s.concat("s")).to_sym
    
    define_method long do
      self*mult
    end
    alias_method short , long
    alias_method plural, long
  }
end


