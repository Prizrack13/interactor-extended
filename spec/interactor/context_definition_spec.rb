# frozen_string_literal: true

RSpec.describe Interactor::ContextDefinition do
  let(:interactor) do
    build_interactor do
      input :a, Integer
      input :b, String
      input :c, [Integer, String]
      input :d, String, array: true
      input :e, String, required: true
      input :f, String, default: 'foo'
      input :g, String, array: true, default: -> { [] }
      output :data, Hash
      def call
        self.data = {
          a:,
          b:,
          c:,
          d:,
          e:,
          f:,
          g:
        }
      end
    end
  end

  it 'validations works' do
    result = interactor.call(a: 1, b: 2)
    expect(result.success?).to eq(false)
    expect(result.errors.keys).to eq(%i[b e])
  end

  it 'read/write/default methods works' do
    result = interactor.call(a: 1, b: '2', c: 3, e: 'e')
    expect(result.success?).to eq(true)
    expect(result.data).to eq({ a: 1, b: '2', c: 3, d: nil, e: 'e', f: 'foo', g: [] })
  end

  describe ':boolean type' do
    let(:interactor) do
      build_interactor do
        input :flag, :boolean
        output :result, :boolean
        def call = self.result = (flag)
      end
    end

    it 'accepts TrueClass' do
      expect(interactor.call(flag: true).success?).to be true
    end

    it 'accepts FalseClass' do
      expect(interactor.call(flag: false).success?).to be true
    end

    it 'rejects non-boolean' do
      result = interactor.call(flag: 'yes')
      expect(result.success?).to be false
    end
  end

  describe 'input with writer: true' do
    let(:interactor) do
      build_interactor do
        input :val, String, writer: true
        def call = self.val = ('written')
      end
    end

    it 'defines a setter for the input' do
      result = interactor.call(val: 'original')
      expect(result.val).to eq('written')
    end
  end

  describe 'Proc default with arity' do
    let(:interactor) do
      build_interactor do
        input :computed, String, default: ->(_interactor, ctx) { ctx[:base].upcase }
        def call; end
      end
    end

    it 'receives interactor and context as arguments' do
      result = interactor.call(base: 'hello')
      expect(result.computed).to eq('HELLO')
    end
  end

  describe '.all_attributes' do
    let(:parent) do
      build_interactor do
        input :x, Integer
        def call; end
      end
    end

    it 'aggregates attributes from the class hierarchy' do
      child = Class.new(parent).tap do |c|
        c.class_eval do
          input :y, String
        end
      end
      attrs = child.all_attributes
      expect(attrs.keys).to include(:x, :y)
    end

    it 'caches the result' do
      expect(interactor.all_attributes).to be(interactor.all_attributes)
    end
  end

  describe '.remove_all_attributes!' do
    it 'clears the all_attributes cache' do
      first = interactor.all_attributes
      interactor.remove_all_attributes!
      second = interactor.all_attributes
      expect(first).not_to be(second)
    end
  end

  describe 'error messages' do
    it 'includes direction and key in the error message' do
      result = interactor.call(a: 1, b: 2, e: 'e')
      expect(result.errors[:b].first).to match(/Input param "b" is not kind of String/)
    end

    it 'includes required error message' do
      result = interactor.call(a: 1, b: '2')
      expect(result.errors[:e].first).to match(/required/)
    end
  end
end
