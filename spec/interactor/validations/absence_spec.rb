# frozen_string_literal: true

RSpec.describe Interactor::Validations::Absence do
  it 'passes for nil' do
    i = interactor_with { input :deleted_at, absence: true }
    expect(i.call(deleted_at: nil).success?).to be true
  end

  it 'passes for empty string' do
    i = interactor_with { input :notes, absence: true }
    expect(i.call(notes: '').success?).to be true
  end

  it 'fails for non-blank values' do
    i = interactor_with { input :deleted_at, absence: true }
    expect(i.call(deleted_at: Time.now).success?).to be false
    expect(i.call(deleted_at: 'yes').success?).to be false
  end

  it 'passes for whitespace-only string (blank)' do
    i = interactor_with { input :notes, absence: true }
    expect(i.call(notes: '   ').success?).to be true
  end

  it 'passes for empty hash' do
    i = interactor_with { input :meta, absence: true }
    expect(i.call(meta: {}).success?).to be true
  end

  it 'fails for non-empty hash' do
    i = interactor_with { input :meta, absence: true }
    expect(i.call(meta: { a: 1 }).success?).to be false
  end

  it 'message includes param label' do
    i = interactor_with { input :field, absence: true }
    expect(i.call(field: 'x').errors[:field].first).to eq('Input param "field" must be blank')
  end

  it 'supports custom message' do
    i = interactor_with { input :field, absence: { message: 'must be empty' } }
    expect(i.call(field: 'x').errors[:field].first).to eq('must be empty')
  end
end
