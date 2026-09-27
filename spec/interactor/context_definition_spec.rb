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

  describe 'Boolean class' do
    let(:interactor) do
      build_interactor do
        input :flag, Interactor::Boolean
        def call; end
      end
    end

    it 'accepts true' do
      expect(interactor.call(flag: true).success?).to be true
    end

    it 'accepts false' do
      expect(interactor.call(flag: false).success?).to be true
    end

    it 'rejects non-boolean' do
      result = interactor.call(flag: 'yes')
      expect(result.success?).to be false
    end

    it 'also works via type: keyword' do
      i = build_interactor do
        input :flag, type: Interactor::Boolean
        def call; end
      end
      expect(i.call(flag: true).success?).to be true
      expect(i.call(flag: 'yes').success?).to be false
    end
  end

  describe 'type: keyword syntax' do
    let(:interactor) do
      build_interactor do
        input :n, type: Integer
        input :s, type: String
        output :result, type: Hash
        def call = self.result = { n:, s: }
      end
    end

    it 'accepts values of the declared type' do
      result = interactor.call(n: 1, s: 'hello')
      expect(result.success?).to be true
      expect(result.result).to eq({ n: 1, s: 'hello' })
    end

    it 'rejects values of the wrong type' do
      result = interactor.call(n: 'not_int', s: 'hello')
      expect(result.success?).to be false
      expect(result.errors[:n].first).to match(/Input param "n" is not kind of Integer/)
    end

    it 'accepts :boolean symbol via type: keyword' do
      i = build_interactor do
        input :flag, type: :boolean
        def call; end
      end
      expect(i.call(flag: true).success?).to be true
      expect(i.call(flag: 'yes').success?).to be false
    end
  end

  describe 'inclusion:' do
    let(:interactor) do
      build_interactor do
        input :currency, inclusion: %w[EUR USD]
        def call; end
      end
    end

    it 'passes when value is in the list' do
      expect(interactor.call(currency: 'EUR').success?).to be true
    end

    it 'fails when value is not in the list' do
      result = interactor.call(currency: 'GBP')
      expect(result.success?).to be false
      expect(result.errors[:currency].first).to match(/not included in/)
    end

    it 'supports a per-validator custom message via validations:' do
      i = build_interactor do
        input :currency, validations: [{ inclusion: %w[EUR USD], message: 'invalid currency' }]
        def call; end
      end
      expect(i.call(currency: 'GBP').errors[:currency].first).to eq('invalid currency')
    end

    it 'accepts hash form with in: and inline message' do
      i = build_interactor do
        input :currency, inclusion: { in: %w[EUR USD], message: 'bad currency' }
        def call; end
      end
      expect(i.call(currency: 'EUR').success?).to be true
      expect(i.call(currency: 'GBP').errors[:currency].first).to eq('bad currency')
    end
  end

  describe 'exclusion:' do
    let(:interactor) do
      build_interactor do
        input :status, exclusion: %w[banned suspended]
        def call; end
      end
    end

    it 'passes when value is not in the list' do
      expect(interactor.call(status: 'active').success?).to be true
    end

    it 'fails when value is in the exclusion list' do
      result = interactor.call(status: 'banned')
      expect(result.success?).to be false
      expect(result.errors[:status].first).to match(/excluded/)
    end

    it 'accepts hash form with in: and inline message' do
      i = build_interactor do
        input :status, exclusion: { in: %w[banned], message: 'not allowed' }
        def call; end
      end
      expect(i.call(status: 'active').success?).to be true
      expect(i.call(status: 'banned').errors[:status].first).to eq('not allowed')
    end
  end

  describe 'validate:' do
    context 'with a Symbol' do
      let(:interactor) do
        build_interactor do
          input :email, validate: :valid_email?
          def call; end
          def valid_email? = context[:email].to_s.include?('@')
        end
      end

      it 'passes when the method returns truthy' do
        expect(interactor.call(email: 'a@b.com').success?).to be true
      end

      it 'fails when the method returns falsy' do
        result = interactor.call(email: 'bad')
        expect(result.success?).to be false
        expect(result.errors[:email].first).to match(/invalid/)
      end
    end

    context 'with a Proc receiving the value' do
      let(:interactor) do
        build_interactor do
          input :age, validate: ->(v) { v >= 18 }
          def call; end
        end
      end

      it 'passes when the proc returns truthy' do
        expect(interactor.call(age: 20).success?).to be true
      end

      it 'fails when the proc returns falsy' do
        expect(interactor.call(age: 16).success?).to be false
      end
    end

    context 'with a zero-arity Proc using self' do
      let(:interactor) do
        build_interactor do
          input :amount, validate: -> { context[:amount] > context[:minimum] }
          def call; end
        end
      end

      it 'evaluates against context' do
        expect(interactor.call(amount: 10, minimum: 5).success?).to be true
        expect(interactor.call(amount: 3, minimum: 5).success?).to be false
      end
    end

    context 'returning a String error message' do
      let(:interactor) do
        build_interactor do
          input :code, validate: ->(v) { 'must be exactly 3 chars' unless v.length == 3 }
          def call; end
        end
      end

      it 'uses the returned string as the error message' do
        result = interactor.call(code: 'ab')
        expect(result.errors[:code].first).to eq('must be exactly 3 chars')
      end

      it 'passes when validate returns nil (truthy check skipped)' do
        expect(interactor.call(code: 'abc').success?).to be true
      end
    end
  end

  describe 'validations: (multiple validators)' do
    let(:interactor) do
      build_interactor do
        input :currency, validations: [
          { type: String, message: 'must be a string' },
          { inclusion: %w[EUR USD], message: 'must be EUR or USD' }
        ]
        def call; end
      end
    end

    it 'passes all validations' do
      expect(interactor.call(currency: 'EUR').success?).to be true
    end

    it 'fails the type check first' do
      result = interactor.call(currency: 123)
      expect(result.errors[:currency].first).to eq('must be a string')
    end

    it 'fails the inclusion check when type passes' do
      result = interactor.call(currency: 'GBP')
      expect(result.errors[:currency].first).to eq('must be EUR or USD')
    end
  end

  describe 'combined type + inclusion' do
    let(:interactor) do
      build_interactor do
        input :currency, String, inclusion: %w[EUR USD]
        def call; end
      end
    end

    it 'passes when type and value match' do
      expect(interactor.call(currency: 'EUR').success?).to be true
    end

    it 'collects multiple errors when several validators fail' do
      result = interactor.call(currency: 42)
      expect(result.errors[:currency].length).to eq(2)
      expect(result.errors[:currency]).to include(match(/not kind of String/), match(/not included in/))
    end

    it 'fails inclusion only when type is correct but value not listed' do
      result = interactor.call(currency: 'GBP')
      expect(result.errors[:currency]).to eq([result.errors[:currency].first])
      expect(result.errors[:currency].first).to match(/not included in/)
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

  describe 'unknown option' do
    it 'raises ArgumentError at class definition time' do
      expect do
        build_interactor do
          input :name, typo: true
          def call; end
        end
      end.to raise_error(ArgumentError, /Unknown option\(s\): :typo/)
    end
  end

  describe 'custom registered validator (min_length:)' do
    before do
      stub_const('MinLengthValidator', Class.new(Interactor::Validations::Base) do
        register_as :min_length

        def initialize(value, options)
          super
          @min = value.is_a?(Hash) ? value.fetch(:min, 0) : value
        end

        def validate(value, _interactor)
          value.nil? || value.length >= @min ? nil : false
        end

        protected

        def default_message
          "#{param_label} is too short (minimum #{@min})"
        end
      end)
    end

    after { Interactor::Validations.unregister(MinLengthValidator) }

    it 'auto-discovers the registered key in extract_options' do
      i = build_interactor do
        input :code, min_length: 3
        def call; end
      end
      expect(i.call(code: 'abc').success?).to be true
      expect(i.call(code: 'ab').errors[:code].first).to match(/too short/)
    end

    it 'supports inline message via hash form' do
      i = build_interactor do
        input :code, min_length: { min: 3, message: 'need 3 chars' }
        def call; end
      end
      expect(i.call(code: 'ab').errors[:code].first).to eq('need 3 chars')
    end
  end

  describe 'required: with inline message' do
    it 'accepts hash form with message:' do
      i = build_interactor do
        input :name, required: { message: 'name is mandatory' }
        def call; end
      end
      expect(i.call(name: nil).errors[:name].first).to eq('name is mandatory')
      expect(i.call(name: 'Alice').success?).to be true
    end
  end

  describe 'validate: with inline message' do
    it 'accepts hash form with: and message:' do
      i = build_interactor do
        input :age, validate: { with: ->(v) { v >= 18 }, message: 'must be adult' }
        def call; end
      end
      expect(i.call(age: 20).success?).to be true
      expect(i.call(age: 16).errors[:age].first).to eq('must be adult')
    end
  end
end
