require 'thread'

class Object

  def deep_copy
    Marshal.load(Marshal.dump(self))
  end

  # So that the tests for once can force thread-safety issues to come
  # out of hiding

  def once_hook_set_value
  end

end

class Module

  def implement_once(ids, variable_prefix)
    for id in ids
      alphanumeric_name = id.to_s.gsub('?', 'q')
      new_name = "gen_#{alphanumeric_name}"
      mutex_name = "mutex_#{alphanumeric_name}"
      return if private_method_defined?(new_name)
      module_eval <<-"end;"
      alias_method :#{new_name}, :#{id}
        private :#{new_name}
        def #{id}(*args, &block)
          Thread.exclusive do
            @#{mutex_name} ||= Mutex.new
          end
          @#{mutex_name}.synchronize do
            unless #{variable_prefix}#{new_name}
              once_hook_set_value
              #{variable_prefix}#{new_name} = [#{new_name}(*args, &block)]
            end
            #{variable_prefix}#{new_name}[0]
          end
        end
      end;
    end
  end

  # Modified from code in the Pickaxe book
  #
  # Warning: Does not work on inherited or redefined methods

  def once(*ids)
    implement_once(ids, '@')
  end

  # Modified from code in the Pickaxe book
  #
  # Warning: Does not work on inherited or redefined methods

  def global_once(*ids)
    implement_once(ids, '$')
  end

end

module Kernel
  def with(o, &block)
    o.instance_eval(&block)
  end
end
