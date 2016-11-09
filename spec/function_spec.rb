require 'spec_helper'

describe Arity::Function do

  class Pair; def call(a,b); [a,b]; end; end

  def n_tuple(*many); many; end

  context 'instantiation' do
    it 'cannot be created using .new' do
      expect{
        described_class.new(->(){})
      }.to raise_error NoMethodError, /private method/
    end

    it 'can be created using .make' do
      expect(described_class.make(->(){})).to be_a described_class
    end

    it 'raises if not callable' do
      expect{
        described_class.make(:symbol)
      }.to raise_error Arity::NotCallableError
    end

    it 'returns nil if silent and not callable' do
      expect(described_class.make(:symbol, silent: true)).to be_nil
    end

    it 'sets the .callable reader' do
      closure = ->(){}
      function = described_class.make(closure)
      expect(function.callable).to equal closure
    end

    it 'properly handles Method objects' do
      method = method(:puts)
      function = described_class.make(method)
      expect(function.callable).to equal method
    end

    it 'unwraps callable objects' do
      receiver = Pair.new
      function = described_class.make(receiver)
      expect(function.callable).to eql receiver.method(:call)
    end
  end

  describe '.arity' do
    it 'delegates to the .callable' do
      dbl = double(call: true)
      expect(dbl).to receive(:arity).and_return(9001)
      fn = described_class.make(dbl)
      expect(fn.arity).to eql 9001
    end

    it 'is correct for unwrapped callables' do
      expect(described_class.make(Pair.new).arity).to eql 2
    end

    it 'is correct for method objects' do
      expect(described_class.make(method(:n_tuple)).arity).to eql(-1)
    end

    it 'is correct for procs' do
      expect(described_class.make(->(){}).arity).to eql(0)
    end
  end

  describe '.signature' do
    #
  end

  describe '.takes?' do
    #
  end

  describe '.runnable?' do
    #
  end

  describe '.run' do
    #
  end

end
