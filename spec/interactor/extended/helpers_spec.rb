# frozen_string_literal: true

RSpec.describe Interactor::Extended::Helpers do
  let(:klass_with_helpers) { Class.new.send(:include, described_class).new }
  describe '#deep_dup' do
    it 'duplicates a hash' do
      original = { a: 1, b: { c: 2 } }
      duplicated = klass_with_helpers.deep_dup(original)
      expect(duplicated).to eq(original)
      expect(duplicated).not_to be(original)
      expect(duplicated[:b]).not_to be(original[:b])
    end

    it 'duplicates an array' do
      original = [1, { a: 2 }, [3]]
      duplicated = klass_with_helpers.deep_dup(original)
      expect(duplicated).to eq(original)
      expect(duplicated).not_to be(original)
      expect(duplicated[1]).not_to be(original[1])
      expect(duplicated[2]).not_to be(original[2])
    end

    it 'returns primitives as-is' do
      [nil, true, false, :sym, 1, 1.5].each do |obj|
        expect(klass_with_helpers.deep_dup(obj)).to eq(obj)
      end
    end
  end

  describe '#deep_transform_keys' do
    it 'transforms hash keys' do
      original = { 'a' => 1, 'b' => { 'c' => 2 } }
      transformed = klass_with_helpers.deep_transform_keys(original, &:to_sym)
      expect(transformed).to eq({ a: 1, b: { c: 2 } })
    end

    it 'transforms array elements' do
      original = [{ 'a' => 1 }, { 'b' => 2 }]
      transformed = klass_with_helpers.deep_transform_keys(original, &:to_sym)
      expect(transformed).to eq([{ a: 1 }, { b: 2 }])
    end
  end

  describe '#deep_dup' do
    it 'dups custom objects' do
      klass = Struct.new(:value)
      obj = klass.new(42)
      duped = klass_with_helpers.deep_dup(obj)
      expect(duped).to eq(obj)
      expect(duped).not_to be(obj)
    end
  end

  describe '#deep_transform_keys' do
    it 'returns non-hash/non-array values unchanged' do
      expect(klass_with_helpers.deep_transform_keys(42) { |k| k }).to eq(42)
      expect(klass_with_helpers.deep_transform_keys('str') { |k| k }).to eq('str')
      expect(klass_with_helpers.deep_transform_keys(nil) { |k| k }).to be_nil
    end
  end

  describe '#safe_constantize' do
    it 'constantizes a valid class' do
      expect(klass_with_helpers.safe_constantize('String')).to eq(String)
    end

    it 'returns nil for an unknown constant' do
      expect(klass_with_helpers.safe_constantize('NonExistentClass::XYZ')).to be_nil
    end

    it 'constantizes a nested constant' do
      expect(klass_with_helpers.safe_constantize('Interactor::Extended::Configuration')).to \
        eq(Interactor::Extended::Configuration)
    end
  end
end
