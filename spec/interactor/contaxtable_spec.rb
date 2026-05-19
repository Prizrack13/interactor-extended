# frozen_string_literal: true

RSpec.describe Interactor::Contextable do
  let(:interactor) do
    build_interactor do
      input :a, Integer
      output :data, Hash
      def call
        self.data = context.to_h
      end

      def rollback
        ctx.rollback = true
      end
    end
  end

  it 'return correct info' do
    ctx = interactor.call!(a: 1)
    expect(ctx.is_a?(Interactor::LightContext)).to eq(true)
    expect(ctx.a).to eq(1)
    expect(ctx[:a]).to eq(1)
    expect(ctx.data).to eq({ a: 1 })
    expect(ctx[:data]).to eq({ a: 1 })
    expect(ctx.success?).to eq(true)
    expect(ctx.failure?).to eq(false)
    expect(ctx._called.length).to eq(1)
    expect(ctx[:rollback]).to eq(nil)
    expect(ctx.rollback!).to eq(true)
    expect(ctx[:rollback]).to eq(true)
    expect { ctx.fail!(error: 'test') }.to raise_error(Interactor::Failure)
    expect(ctx.error).to eq('test')
  end
end
