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

  context 'examples' do
    let(:function) { described_class.make(proc) }

    context 'zero args' do
      let(:proc) { ->(){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 0, any_key: false,
            required_keys: [], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when 0,[]' do
          expect(function.takes?(arg_count: 0, keywords: [])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 1, keywords: [])).to eql false
          expect(function.takes?(arg_count: 0, keywords: [:a])).to eql false
        end
      end
    end

    context 'the splat operator' do
      let(:proc) { ->(*args){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: -1, any_key: false,
            required_keys: [], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when *,[]' do
          expect(function.takes?(arg_count: 0, keywords: [])).to eql true
          expect(function.takes?(arg_count: 1, keywords: [])).to eql true
          expect(function.takes?(arg_count: 9001, keywords: [])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 1, keywords: [:a])).to eql false
        end
      end
    end

    context 'one required arg' do
      let(:proc) { ->(a){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 1, max_args: 1, any_key: false,
            required_keys: [], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when 1,[]' do
          expect(function.takes?(arg_count: 1, keywords: [])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 0, keywords: [])).to eql false
          expect(function.takes?(arg_count: 2, keywords: [])).to eql false
          expect(function.takes?(arg_count: 1, keywords: [:a])).to eql false
        end
      end
    end

    context 'two required args' do
      let(:proc) { ->(a,b){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 2, max_args: 2, any_key: false,
            required_keys: [], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when 2,[]' do
          expect(function.takes?(arg_count: 2, keywords: [])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 1, keywords: [])).to eql false
          expect(function.takes?(arg_count: 3, keywords: [])).to eql false
          expect(function.takes?(arg_count: 2, keywords: [:a])).to eql false
        end
      end
    end

    context 'one required and one optional arg' do
      let(:proc) { ->(a,b=5){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 1, max_args: 2, any_key: false,
            required_keys: [], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when {1,2},[]' do
          expect(function.takes?(arg_count: 1, keywords: [])).to eql true
          expect(function.takes?(arg_count: 2, keywords: [])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 0, keywords: [])).to eql false
          expect(function.takes?(arg_count: 3, keywords: [])).to eql false
          expect(function.takes?(arg_count: 1, keywords: [:a])).to eql false
          expect(function.takes?(arg_count: 2, keywords: [:b])).to eql false
        end
      end
    end

    context 'two required args, one optional arg, and splat' do
      let(:proc) { ->(a,b,c=5,*rest){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 2, max_args: -1, any_key: false,
            required_keys: [], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when >=2, []' do
          expect(function.takes?(arg_count: 2, keywords: [])).to eql true
          expect(function.takes?(arg_count: 3, keywords: [])).to eql true
          expect(function.takes?(arg_count: 4, keywords: [])).to eql true
          expect(function.takes?(arg_count: 9001, keywords: [])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 0, keywords: [])).to eql false
          expect(function.takes?(arg_count: 1, keywords: [])).to eql false
          expect(function.takes?(arg_count: 2, keywords: [:a])).to eql false
        end
      end
    end

    context 'a single required kwarg' do
      let(:proc) { ->(foo:){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 0, any_key: false,
            required_keys: [:foo], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when 0,[:foo]' do
          expect(function.takes?(arg_count: 0, keywords: [:foo])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 1, keywords: [:foo])).to eql false
          expect(function.takes?(arg_count: 0, keywords: [:bar])).to eql false
          expect(function.takes?(arg_count: 0, keywords: [])).to eql false
        end
      end
    end

    context 'two required kwargs' do
      let(:proc) { ->(foo:, bar:){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 0, any_key: false,
            required_keys: [:foo, :bar], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when 0,[:foo,:bar]' do
          expect(function.takes?(arg_count: 0, keywords: [:foo,:bar])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 0, keywords: [:foo])).to eql false
          expect(function.takes?(arg_count: 0, keywords: [:bar])).to eql false
          expect(function.takes?(arg_count: 0, keywords: [:foo,:bar,:baz])).to eql false
          expect(function.takes?(arg_count: 1, keywords: [:foo,:bar])).to eql false
        end
      end
    end

    context 'one required and one optional kwarg' do
      let(:proc) { ->(foo: 5, bar:){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 0, any_key: false,
            required_keys: [:bar], optional_keys: [:foo]
          })
        end
      end
      describe '.takes?' do
        it 'is true when 0,[:bar]' do
          expect(function.takes?(arg_count: 0, keywords: [:bar])).to eql true
        end

        it 'is true when 0,[:foo,:bar]' do
          expect(function.takes?(arg_count: 0, keywords: [:foo,:bar])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:bar,:foo])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 0, keywords: [:foo])).to eql false
          expect(function.takes?(arg_count: 0, keywords: [:foo,:bar,:baz])).to eql false
          expect(function.takes?(arg_count: 1, keywords: [:foo,:bar])).to eql false
        end
      end
    end

    context 'all optional kwargs' do
      let(:proc) { ->(foo: 5, bar:6, baz: 7){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 0, any_key: false,
            required_keys: [], optional_keys: [:foo,:bar,:baz]
          })
        end
      end
      describe '.takes?' do
        it 'is true when 0,[]' do
          expect(function.takes?(arg_count: 0, keywords: [])).to eql true
        end

        it 'is true when 0,[{:foo,:bar,:baz}+]' do
          expect(function.takes?(arg_count: 0, keywords: [:foo])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:bar])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:baz])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:foo,:bar])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:foo,:baz])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:bar,:baz])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:foo,:bar,:baz])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 1, keywords: [])).to eql false
          expect(function.takes?(arg_count: 0, keywords: [:bax])).to eql false
        end
      end
    end

    context 'the double splat operator' do
      let(:proc) { ->(**opts){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 0, any_key: true,
            required_keys: [], optional_keys: []
          })
        end
      end
      describe '.takes?' do
        it 'is true when 0,[anything*]' do
          expect(function.takes?(arg_count: 0, keywords: [])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:asdf])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:qqq,:www,:eee])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 1, keywords: [:asdf])).to eql false
        end
      end
    end

    context 'required and optional kwargs with double splat' do
      let(:proc) { ->(a:1,b:2,c:3,name:,**opts){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 0, any_key: true,
            required_keys: [:name], optional_keys: [:a,:b,:c]
          })
        end
      end
      describe '.takes?' do
        it 'is true when 0,[:name,anything*]' do
          expect(function.takes?(arg_count: 0, keywords: [:name])).to eql true
          expect(function.takes?(arg_count: 0, keywords: [:name,:b,:x,:y])).to eql true
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 0, keywords: [:a,:c])).to eql false
          expect(function.takes?(arg_count: 1, keywords: [:name])).to eql false
        end
      end
    end

    context 'a mix of args and opts' do
      let(:proc) { ->(one=1,two=2,three=3,name:,date:,log:false){} }
      describe '.signature' do
        it 'is correct' do
          expect(function.signature).to eql({
            min_args: 0, max_args: 3, any_key: false,
            required_keys: [:name, :date], optional_keys: [:log]
          })
        end
      end
      describe '.takes?' do
        it 'is true when <=3, [:name,:date]' do
          (0..3).each do |n|
            expect(function.takes?(arg_count: n, keywords: [:name,:date])).to eql true
          end
        end

        it 'is true when <=3, [:name,:date,:log]' do
          (0..3).each do |n|
            expect(function.takes?(arg_count: n, keywords: [:name,:log,:date])).to eql true
          end
        end

        it 'is false otherwise' do
          expect(function.takes?(arg_count: 7, keywords: [:name,:date])).to eql false
          expect(function.takes?(arg_count: 2, keywords: [:name])).to eql false
          expect(function.takes?(arg_count: 2, keywords: [:date])).to eql false
          expect(function.takes?(arg_count: 2, keywords: [:name,:date,:other])).to eql false
        end
      end
    end
  end

  describe '.runnable?' do
    it 'delegates to .takes? with the parameter counts' do
      function = described_class.make(->(){})
      expect(function).to receive(:takes?).with(arg_count: 2, keywords: [:a,:b,:c])
      function.runnable?(42,9001,a:'A',b:'B',c:'C')
    end
  end

  describe '.run' do
    it 'calls the callable with the given parameters' do
      function = described_class.make(->(){})
      expect(function.callable).to receive(:call).with(42,9001,a:'A',b:'B',c:'C')
      function.run(42,9001,a:'A',b:'B',c:'C')
    end
  end

end
