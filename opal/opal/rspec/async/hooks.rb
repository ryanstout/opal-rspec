class RSpec::Core::Hooks::HookCollection
  def run
    hooks.inject(Promise.value) do |previous_hook_promise, next_hook|
      previous_hook_promise.then do
        result = next_hook.run @example
        Promise.value result
      end
    end
  end
end

# Need to be able to work with a promise, but without modifying proxy, we can't get a promise back from our around hook
# therefore, modify this so that we pass a promise in
class RSpec::Core::Hooks::AroundHook
  def execute_with_promise(use_promise, example, procsy)
    Promise.value(example.instance_exec(procsy, &block)).then do
      unless procsy.executed?
        Pending.mark_skipped!(example, "#{hook_description} did not execute the example")
      end
      use_promise.resolve
    end
  end
end

# This is an odd one because of the way around hooks subclass themselves. We mirror the original code, we just carry
# around a promise with the procsy
class RSpec::Core::Hooks::AroundHookCollection
  def run
    seed = [@initial_procsy, Promise.value]
    last_procsy, last_promise = hooks.inject(seed) do |procsy_and_around_hook_promise, around_hook|
      procsy, previous_hook_promise = procsy_and_around_hook_promise
      new_hook_promise = Promise.new
      new_procsy = procsy.wrap do
        previous_hook_promise.then do
          around_hook.execute_with_promise new_hook_promise, @example, procsy
        end.rescue do |ex|
          # because of the way Procsy works, we need to set this here and not in the execute_with_promise method
          new_hook_promise.reject ex
        end
      end
      [new_procsy, new_hook_promise]
    end
    last_procsy.call
    last_promise        
  end
end
