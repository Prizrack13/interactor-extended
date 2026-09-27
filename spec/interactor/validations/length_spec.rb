# frozen_string_literal: true

RSpec.describe Interactor::Validations::Length do
  it 'enforces minimum' do
    i = interactor_with { input :name, length: { minimum: 3 } }
    expect(i.call(name: 'Al').success?).to be false
    expect(i.call(name: 'Ali').success?).to be true
    expect(i.call(name: nil).success?).to be true
  end

  it 'enforces maximum' do
    i = interactor_with { input :code, length: { maximum: 5 } }
    expect(i.call(code: 'abcdef').success?).to be false
    expect(i.call(code: 'abc').success?).to be true
  end

  it 'enforces exact length with is:' do
    i = interactor_with { input :pin, length: { is: 4 } }
    expect(i.call(pin: '1234').success?).to be true
    expect(i.call(pin: '123').success?).to be false
    expect(i.call(pin: '12345').success?).to be false
  end

  it 'enforces range with in:' do
    i = interactor_with { input :bio, length: { in: 10..200 } }
    expect(i.call(bio: 'x' * 10).success?).to be true
    expect(i.call(bio: 'x' * 9).success?).to be false
    expect(i.call(bio: 'x' * 201).success?).to be false
  end

  it 'includes direction and key in default message' do
    i = interactor_with { input :name, length: { minimum: 3 } }
    expect(i.call(name: 'Al').errors[:name].first).to match(/Input param "name" is too short/)
  end

  it 'works on arrays' do
    i = interactor_with { input :tags, length: { minimum: 1 } }
    expect(i.call(tags: []).success?).to be false
    expect(i.call(tags: ['a']).success?).to be true
  end

  it 'message for is: says wrong length' do
    i = interactor_with { input :pin, length: { is: 4 } }
    expect(i.call(pin: '12').errors[:pin].first).to eq('Input param "pin" is the wrong length (should be 4)')
  end

  it 'message for minimum + maximum says between' do
    i = interactor_with { input :bio, length: { minimum: 2, maximum: 10 } }
    expect(i.call(bio: 'x').errors[:bio].first).to eq('Input param "bio" length must be between 2 and 10')
  end

  it 'message for maximum-only says too long' do
    i = interactor_with { input :code, length: { maximum: 5 } }
    expect(i.call(code: 'toolong').errors[:code].first).to eq('Input param "code" is too long (maximum is 5)')
  end

  it 'supports custom message' do
    i = interactor_with { input :name, length: { minimum: 3, message: 'too short' } }
    expect(i.call(name: 'ab').errors[:name].first).to eq('too short')
  end
end
