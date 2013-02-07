if RUBY_VERSION >= '1.8'
  require 'pp'
  require 'yaml'
end

class Object

  def tapq
    tap do |o|
      q o
    end
  end

  def tapqq
    tap do |o|
      qq o
    end
  end

  # Mostly Like p, but writes to $stderr instead of $stdout But not
  # exactly like p: you can give it a block that returns a list of
  # expressions as strings or symbols.  Those expressions will be
  # evaluted and displayed with labels.

  def q(*stuff, &block)
    qprint(nil, *stuff, &block)
  end

  def ql(*stuff, &block)
    qprint(process_caller_line(caller[0], true), *stuff, &block)
  end

  def qlf(*stuff, &block)
    qprint(process_caller_line(caller[0], false), *stuff, &block)
  end

  def qprint(prefix, *stuff, &block)
    if block
      s = Array(block[]).collect do |expression|
        value = eval(expression.to_s, block.binding).inspect
        "#{expression} = #{value}"
      end.join(', ')
      s = "#{prefix} " + s if prefix
      $stderr.puts s
    else
      if prefix
        $stderr.print prefix
        if stuff.empty?
          $stderr.print "\n"
        end
      end
      stuff.each_with_index do |thing, i|
        s = thing.inspect + "\n"
        if prefix
          if i != 0
            s = " " * prefix.size + s
          end
          s = " " + s
        end
        $stderr.print(s)
      end
    end
  end

  def process_caller_line(str, basename_only)
    parts = str.split(':')[0..1]
    if basename_only
      parts[0] = File.basename(parts[0])
    end
    parts.join(':') + ":"
  end
  # like pp, but writes to $stderr instead of $stdout

  if RUBY_VERSION >= '1.8'
    def qq(*objs)
      for obj in objs
        PP.pp(obj, $stderr)
      end
    end
  end

  # like y, but writes to $stderr instead of $stdout

  if RUBY_VERSION >= '1.8'
    def yy(*objs)
      for obj in objs
        $stderr.puts obj.to_yaml(:SortKeys=>true)
      end
    end
  end

end
