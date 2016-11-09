require 'spec_helper'

describe Arity::Function do

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
  end

  describe '.arity' do
    #
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
