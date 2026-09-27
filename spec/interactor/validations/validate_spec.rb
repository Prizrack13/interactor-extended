# frozen_string_literal: true

RSpec.describe Interactor::Validations::Validate do
  describe 'symbol validator' do
    it 'passes when method returns truthy' do
      i = interactor_with do
        input :email, validate: :valid?
        define_method(:valid?) { true }
      end
      expect(i.call(email: 'a@b.com').success?).to be true
    end

    it 'fails when method returns falsy' do
      i = interactor_with do
        input :email, validate: :valid?
        define_method(:valid?) { false }
      end
      expect(i.call(email: 'bad').success?).to be false
    end

    it 'uses string return as the error message directly' do
      i = interactor_with do
        input :email, validate: :check_email
        define_method(:check_email) { 'not a valid email' }
      end
      expect(i.call(email: 'bad').errors[:email].first).to eq('not a valid email')
    end

    it 'skips nil values' do
      called = false
      i = interactor_with do
        input :email, validate: :check
        define_method(:check) { called = true; true }
      end
      i.call(email: nil)
      expect(called).to be false
    end
  end

  describe 'proc validator' do
    it 'passes when proc returns non-false truthy' do
      i = interactor_with { input :age, validate: ->(v) { v >= 18 } }
      expect(i.call(age: 18).success?).to be true
      expect(i.call(age: 25).success?).to be true
    end

    it 'fails when proc returns false' do
      i = interactor_with { input :age, validate: ->(v) { v >= 18 } }
      expect(i.call(age: 17).success?).to be false
    end

    it 'passes when proc returns nil (not false)' do
      i = interactor_with { input :x, validate: ->(_v) { nil } }
      expect(i.call(x: 'anything').success?).to be true
    end

    it 'uses string return as the error message directly' do
      i = interactor_with { input :code, validate: ->(v) { 'too short' unless v.length == 4 } }
      expect(i.call(code: 'ab').errors[:code].first).to eq('too short')
    end

    it 'passes value as argument for arity-1 proc' do
      received = nil
      i = interactor_with do
        input :x, validate: ->(v) { received = v; true }
      end
      i.call(x: 'hello')
      expect(received).to eq('hello')
    end

    it 'uses instance_exec for zero-arity proc (access to interactor context)' do
      i = interactor_with do
        input :amount, validate: -> { context[:amount] > context[:minimum] }
        input :minimum
      end
      expect(i.call(amount: 10, minimum: 5).success?).to be true
      expect(i.call(amount: 3, minimum: 5).success?).to be false
    end

    it 'skips nil values' do
      called = false
      i = interactor_with do
        input :x, validate: ->(_v) { called = true; true }
      end
      i.call(x: nil)
      expect(called).to be false
    end
  end

  describe 'hash form' do
    it 'supports { with: proc } form' do
      i = interactor_with { input :n, validate: { with: ->(v) { v > 0 } } }
      expect(i.call(n: 1).success?).to be true
      expect(i.call(n: 0).success?).to be false
    end

    it 'supports custom message via { with:, message: }' do
      i = interactor_with { input :n, validate: { with: ->(v) { v > 0 }, message: 'must be positive' } }
      expect(i.call(n: 0).errors[:n].first).to eq('must be positive')
    end

    it 'supports { with: :symbol } form' do
      i = interactor_with do
        input :x, validate: { with: :ok?, message: 'not ok' }
        define_method(:ok?) { false }
      end
      expect(i.call(x: 'val').errors[:x].first).to eq('not ok')
    end
  end
end
