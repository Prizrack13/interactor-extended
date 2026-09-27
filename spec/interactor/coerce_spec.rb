# frozen_string_literal: true

RSpec.describe 'coerce:' do
  it 'coerces via symbol method on the value' do
    i = interactor_with { input :count, coerce: :to_i }
    result = i.call(count: '42')
    expect(result.success?).to be true
    expect(result[:count]).to eq(42)
  end

  it 'coerces via proc' do
    i = interactor_with { input :name, coerce: ->(v) { v.upcase } }
    result = i.call(name: 'alice')
    expect(result.success?).to be true
    expect(result[:name]).to eq('ALICE')
  end

  it 'coerces via class with .parse' do
    parser = Class.new do
      def self.parse(value) = value.to_i * 2
    end
    i = interactor_with { input :n, coerce: parser }
    result = i.call(n: '5')
    expect(result.success?).to be true
    expect(result[:n]).to eq(10)
  end

  it 'skips coercion for nil values' do
    i = interactor_with { input :count, coerce: :to_i }
    result = i.call(count: nil)
    expect(result.success?).to be true
    expect(result[:count]).to be_nil
  end

  it 'coerces before validation so type check sees coerced value' do
    i = interactor_with { input :count, Integer, coerce: :to_i }
    expect(i.call(count: '7').success?).to be true
    expect(i.call(count: 7).success?).to be true
  end

  it 'coerces on output setter (set_attribute)' do
    i = build_interactor do
      output :score, coerce: :to_i
      define_method(:call) { self.score = '99' }
    end
    result = i.call
    expect(result.success?).to be true
    expect(result[:score]).to eq(99)
  end

  it 'coerces after default value is applied' do
    i = interactor_with { input :n, default: '5', coerce: :to_i }
    result = i.call
    expect(result.success?).to be true
    expect(result[:n]).to eq(5)
  end

  it 'coerced value is seen by subsequent validators' do
    i = interactor_with { input :n, String, coerce: :to_s }
    expect(i.call(n: 42).success?).to be true
  end

  it 'coerce + numericality: validates the coerced value' do
    i = interactor_with { input :n, coerce: :to_i, numericality: { greater_than: 0 } }
    expect(i.call(n: '5').success?).to be true
    expect(i.call(n: '0').success?).to be false
  end
end
