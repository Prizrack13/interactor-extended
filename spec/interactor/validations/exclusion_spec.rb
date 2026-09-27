# frozen_string_literal: true

RSpec.describe Interactor::Validations::Exclusion do
  it 'passes when value is not in the list' do
    i = interactor_with { input :role, exclusion: %w[admin superadmin] }
    expect(i.call(role: 'user').success?).to be true
    expect(i.call(role: 'moderator').success?).to be true
  end

  it 'fails when value is in the list' do
    i = interactor_with { input :role, exclusion: %w[admin superadmin] }
    expect(i.call(role: 'admin').success?).to be false
    expect(i.call(role: 'superadmin').success?).to be false
  end

  it 'skips nil values' do
    i = interactor_with { input :role, exclusion: %w[admin] }
    expect(i.call(role: nil).success?).to be true
  end

  it 'supports { in: } hash form' do
    i = interactor_with { input :status, exclusion: { in: %w[banned deleted] } }
    expect(i.call(status: 'active').success?).to be true
    expect(i.call(status: 'banned').success?).to be false
  end

  it 'default message says excluded' do
    i = interactor_with { input :role, exclusion: %w[admin] }
    expect(i.call(role: 'admin').errors[:role].first).to match(/is excluded/)
  end

  it 'supports custom message via hash form' do
    i = interactor_with { input :role, exclusion: { in: %w[admin], message: 'not allowed' } }
    expect(i.call(role: 'admin').errors[:role].first).to eq('not allowed')
  end

  it 'supports custom message in validations: array' do
    i = interactor_with { input :role, validations: [{ exclusion: %w[admin], message: 'forbidden role' }] }
    expect(i.call(role: 'admin').errors[:role].first).to eq('forbidden role')
  end
end
