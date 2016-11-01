require "arity/version"
require "arity/errors"

module Arity
  extend self

  def callable?(fn, takes = nil)
    return false if !is_callable?(fn)
    !takes || unsafe_takes?(fn, takes)
  end

  def takes?(callable, n)
    not_callable_error! if !is_callable?(callable)
    unsafe_takes?(callable, n)
  end

  def arity(callable)
    not_callable_error! if !is_callable?(callable)
    unsafe_arity(callable)
  end

  private

  def is_callable?(fn)
    fn.respond_to?(:call)
  end

  def unsafe_arity(fn)
    fn.respond_to?(:arity) ? fn.arity : fn.method(:call).arity
  end

  def unsafe_takes?(fn, n)
    valid_arities(n).include?(unsafe_arity(fn))
  end

  def valid_arities(n)
    parameter_count_error!(n, "is not an integer") if !n.is_a?(Integer)
    parameter_count_error!(n, "cannot be < 0") if n < 0
    [n] + (-n-1..-1).to_a
  end

  def not_callable_error!(fn)
    raise NotCallableError, "passed function is not callable: #{fn.inspect}"
  end

  def parameter_count_error!(n, suffix)
    raise ParameterCountError, "parameter count (#{n.inspect}) #{suffix}"
  end

end
