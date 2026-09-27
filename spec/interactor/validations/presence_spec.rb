# frozen_string_literal: true

RSpec.describe Interactor::Validations::Presence do
  it 'fails for nil' do
    i = interactor_with { input :name, presence: true }
    expect(i.call(name: nil).success?).to be false
  end

  it 'fails for empty string' do
    i = interactor_with { input :name, presence: true }
    expect(i.call(name: '').success?).to be false
  end

  it 'fails for whitespace-only string' do
    i = interactor_with { input :name, presence: true }
    expect(i.call(name: '   ').success?).to be false
  end

  it 'fails for empty array' do
    i = interactor_with { input :tags, presence: true }
    expect(i.call(tags: []).success?).to be false
  end

  it 'passes for non-blank values' do
    i = interactor_with { input :name, presence: true }
    expect(i.call(name: 'Alice').success?).to be true
    expect(i.call(name: 0).success?).to be true
    expect(i.call(name: false).success?).to be true
  end

  it 'fails for empty hash' do
    i = interactor_with { input :meta, presence: true }
    expect(i.call(meta: {}).success?).to be false
  end

  it 'passes for non-empty hash' do
    i = interactor_with { input :meta, presence: true }
    expect(i.call(meta: { a: 1 }).success?).to be true
  end

  it 'message includes param label' do
    i = interactor_with { input :name, presence: true }
    expect(i.call(name: nil).errors[:name].first).to eq("Input param \"name\" can't be blank")
  end

  it 'supports custom message' do
    i = interactor_with { input :name, presence: { message: 'required field' } }
    expect(i.call(name: nil).errors[:name].first).to eq('required field')
  end
end
