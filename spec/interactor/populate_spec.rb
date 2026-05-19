# frozen_string_literal: true

RSpec.describe Interactor::Populate do
  let(:interactor) do
    build_interactor do
      def call; end
    end
  end
  let(:interactor2) do
    build_interactor do
      def call
        context_assign(c: 3)
      end
    end
  end

  it 'populate context with args' do
    ctx = interactor2.call!({ b: 2 }, interactor.call!(a: 1), :a)
    expect(ctx.to_h.slice(:a, :b, :c)).to eq({ a: 1, b: 2, c: 3 })
  end

  it 'populate context with params' do
    ctx = interactor2.call!(b: 2, context: interactor.call!(a: 1), context_keys: %i[a])
    expect(ctx.to_h.slice(:a, :b, :c)).to eq({ a: 1, b: 2, c: 3 })
  end

  it 'populate context with underscore params' do
    ctx = interactor2.call!(b: 2, context: interactor.call!(_a: 1))
    expect(ctx.to_h.slice(:_a, :b, :c)).to eq({ _a: 1, b: 2, c: 3 })
  end

  describe '#context_assign' do
    it 'returns the context object' do
      interactor_with_assign = build_interactor do
        def call
          ctx_ref = context_assign(x: 42)
          context[:returned_same] = ctx_ref.equal?(context)
        end
      end
      result = interactor_with_assign.call!
      expect(result[:returned_same]).to be true
      expect(result[:x]).to eq(42)
    end

    it 'assigns multiple keys at once' do
      interactor2.call!(c_override: nil)
      result2 = build_interactor do
        def call
          context_assign(p: 1, q: 2, r: 3)
        end
      end.call!
      expect(result2.to_h.slice(:p, :q, :r)).to eq({ p: 1, q: 2, r: 3 })
    end
  end

  describe 'without parent context' do
    it 'runs normally without copying from parent' do
      ctx = interactor.call!(a: 10)
      expect(ctx[:a]).to eq(10)
    end
  end
end
