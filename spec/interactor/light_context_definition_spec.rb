# frozen_string_literal: true

RSpec.describe Interactor::ContextDefinition do
  let(:interactor) do
    build_interactor(Interactor::Operation[:light]) do
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
    expect(result.success?).to eq(true)
    expect(result.errors).to eq(nil)
  end

  it 'read/write/default methods works' do
    result = interactor.call(a: 1, b: '2', c: 3, e: 'e')
    expect(result.success?).to eq(true)
    expect(result.data).to eq({ a: 1, b: '2', c: 3, d: nil, e: 'e', f: nil, g: nil })
  end
end
