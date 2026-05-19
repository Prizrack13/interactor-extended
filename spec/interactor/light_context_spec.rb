# frozen_string_literal: true

RSpec.describe Interactor::LightContext do
  let(:context) { described_class.new(a: 1, b: 'test') }

  describe '#success?' do
    it 'returns true by default' do
      expect(context.success?).to be true
    end

    it 'returns false after fail!' do
      expect { context.fail! }.to raise_error Interactor::Failure
      expect(context.success?).to be false
    end
  end

  describe '#failure?' do
    it 'returns false by default' do
      expect(context.failure?).to be false
    end

    it 'returns true after fail!' do
      expect { context.fail! }.to raise_error Interactor::Failure
      expect(context.failure?).to be true
    end
  end

  describe '#fail!' do
    it 'sets failure flag and raises Failure' do
      expect { context.fail!(error: 'oops') }.to raise_error(Interactor::Failure)
      expect(context.failure?).to be true
      expect(context[:error]).to eq('oops')
    end
  end

  describe '#rollback!' do
    it 'triggers rollback on called interactors' do
      interactor = double(:interactor)
      context.called!(interactor)
      expect(interactor).to receive(:rollback)
      context.rollback!
    end

    it 'prevents double rollback' do
      context.rollback!
      expect(context.rollback!).to be false
    end
  end

  describe '#key?' do
    it 'checks for symbol keys' do
      expect(context.key?(:a)).to be true
      expect(context.key?(:c)).to be false
    end

    it 'checks for string keys' do
      expect(context.key?('a')).to be true
    end
  end

  describe '#[]' do
    it 'retrieves values by symbol' do
      expect(context[:a]).to eq(1)
    end

    it 'retrieves values by string' do
      expect(context['a']).to eq(1)
    end
  end

  describe '#[]=' do
    it 'sets values by symbol' do
      context[:c] = 3
      expect(context[:c]).to eq(3)
    end

    it 'sets values by string' do
      context['c'] = 3
      expect(context[:c]).to eq(3)
    end
  end

  describe '#respond_to?' do
    it 'returns true for existing methods' do
      expect(context.respond_to?(:success?)).to be true
    end

    it 'returns true for dynamic keys' do
      context[:foo] = 'bar'
      expect(context.respond_to?(:foo)).to be true
      expect(context.respond_to?(:foo?)).to be true
      expect(context.respond_to?(:foo=)).to be true
    end
  end

  describe '#deconstruct_keys' do
    it 'returns context data with success/failure flags' do
      keys = context.deconstruct_keys
      expect(keys).to eq({ a: 1, b: 'test', success: true, failure: false })
    end

    it 'filters keys when provided' do
      keys = context.deconstruct_keys([:a])
      expect(keys).to eq({ a: 1 })
    end
  end

  describe '#to_s' do
    it 'returns string representation' do
      expect(context.to_s).to include('a')
      expect(context.to_s).to include('1')
    end
  end

  describe '#method_missing' do
    it 'handles dynamic getters' do
      context[:dynamic] = 'value'
      expect(context.dynamic).to eq('value')
    end

    it 'handles dynamic boolean getters' do
      context[:active] = true
      expect(context.active?).to be true
      context[:active] = false
      expect(context.active?).to be false
      context[:active] = []
      expect(context.active?).to be false
      context[:active] = [1]
      expect(context.active?).to be true
    end

    it 'handles dynamic setters' do
      context.dynamic_setter = 'new_value'
      expect(context[:dynamic_setter]).to eq('new_value')
    end
  end

  describe '.build' do
    it 'returns the context if already a LightContext' do
      ctx = described_class.new
      expect(described_class.build(ctx)).to be(ctx)
    end

    it 'creates a new context from a hash' do
      ctx = described_class.build({ a: 1 })
      expect(ctx[:a]).to eq(1)
    end

    it 'creates an empty context when called with no args' do
      ctx = described_class.build
      expect(ctx.to_h).to eq({})
    end
  end

  describe '#initialize' do
    it 'symbolizes string keys' do
      ctx = described_class.new('a' => 1)
      expect(ctx[:a]).to eq(1)
    end

    it 'defaults to empty hash' do
      ctx = described_class.new
      expect(ctx.to_h).to eq({})
    end
  end

  describe '#to_h' do
    it 'returns a clone so mutations do not affect the context' do
      h = context.to_h
      h[:a] = 999
      expect(context[:a]).to eq(1)
    end
  end

  describe '#inspect' do
    it 'includes the class name and data' do
      expect(context.inspect).to include('LightContext')
      expect(context.inspect).to include('a')
    end
  end

  describe '#_called' do
    it 'starts as an empty array' do
      expect(described_class.new._called).to eq([])
    end

    it 'accumulates called interactors' do
      double1 = double(:i1)
      double2 = double(:i2)
      context.called!(double1)
      context.called!(double2)
      expect(context._called).to eq([double1, double2])
    end
  end

  describe '#rollback!' do
    it 'calls rollback on each called interactor in reverse order' do
      order = []
      i1 = double(:i1)
      i2 = double(:i1)
      allow(i1).to receive(:rollback) { order << :i1 }
      allow(i2).to receive(:rollback) { order << :i2 }
      context.called!(i1)
      context.called!(i2)
      context.rollback!
      expect(order).to eq(%i[i2 i1])
    end
  end
end
