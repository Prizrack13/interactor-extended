# frozen_string_literal: true

RSpec.describe Interactor::Validations::Inclusion do
  it 'passes when value is in the list' do
    i = interactor_with { input :currency, inclusion: %w[EUR USD GBP] }
    expect(i.call(currency: 'EUR').success?).to be true
    expect(i.call(currency: 'GBP').success?).to be true
  end

  it 'fails when value is not in the list' do
    i = interactor_with { input :currency, inclusion: %w[EUR USD] }
    expect(i.call(currency: 'JPY').success?).to be false
  end

  it 'skips nil values' do
    i = interactor_with { input :currency, inclusion: %w[EUR USD] }
    expect(i.call(currency: nil).success?).to be true
  end

  it 'supports { in: } hash form' do
    i = interactor_with { input :status, inclusion: { in: %w[active inactive] } }
    expect(i.call(status: 'active').success?).to be true
    expect(i.call(status: 'deleted').success?).to be false
  end

  it 'works with a Range' do
    i = interactor_with { input :score, inclusion: (1..10) }
    expect(i.call(score: 5).success?).to be true
    expect(i.call(score: 11).success?).to be false
  end

  it 'default message names the list' do
    i = interactor_with { input :role, inclusion: %w[admin user] }
    expect(i.call(role: 'guest').errors[:role].first).to match(/is not included in/)
  end

  it 'supports custom message via hash form' do
    i = interactor_with { input :currency, inclusion: { in: %w[EUR USD], message: 'unsupported currency' } }
    expect(i.call(currency: 'JPY').errors[:currency].first).to eq('unsupported currency')
  end

  it 'supports custom message in validations: array' do
    i = interactor_with { input :type, validations: [{ inclusion: %w[a b], message: 'bad type' }] }
    expect(i.call(type: 'c').errors[:type].first).to eq('bad type')
  end
end
