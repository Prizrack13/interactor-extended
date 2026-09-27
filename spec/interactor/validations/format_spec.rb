# frozen_string_literal: true

RSpec.describe Interactor::Validations::Format do
  it 'accepts shorthand regex' do
    i = interactor_with { input :slug, format: /\A[a-z]+\z/ }
    expect(i.call(slug: 'hello').success?).to be true
    expect(i.call(slug: 'Hello').success?).to be false
  end

  it 'supports with: form' do
    i = interactor_with { input :code, format: { with: /\A\d{4}\z/ } }
    expect(i.call(code: '1234').success?).to be true
    expect(i.call(code: 'abc').success?).to be false
  end

  it 'supports without: form' do
    i = interactor_with { input :name, format: { without: /\d/ } }
    expect(i.call(name: 'Alice').success?).to be true
    expect(i.call(name: 'Alice1').success?).to be false
  end

  it 'skips nil values' do
    i = interactor_with { input :slug, format: /\A[a-z]+\z/ }
    expect(i.call(slug: nil).success?).to be true
  end

  it 'uses custom message' do
    i = interactor_with { input :slug, format: { with: /\A[a-z]+\z/, message: 'lowercase only' } }
    expect(i.call(slug: 'ABC').errors[:slug].first).to eq('lowercase only')
  end

  it 'enforces both with: and without: together' do
    i = interactor_with { input :code, format: { with: /\A[a-z]+\z/, without: /foo/ } }
    expect(i.call(code: 'bar').success?).to be true
    expect(i.call(code: 'foo').success?).to be false
    expect(i.call(code: 'Bar').success?).to be false
  end

  it 'calls to_s on non-string values' do
    i = interactor_with { input :n, format: /\A\d+\z/ }
    expect(i.call(n: 123).success?).to be true
    expect(i.call(n: 12.5).success?).to be false
  end

  it 'default message falls back to param label is invalid' do
    i = interactor_with { input :slug, format: /\A[a-z]+\z/ }
    expect(i.call(slug: 'ABC').errors[:slug].first).to eq('Input param "slug" is invalid')
  end
end
