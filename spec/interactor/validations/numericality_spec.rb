# frozen_string_literal: true

RSpec.describe Interactor::Validations::Numericality do
  it 'passes for any number' do
    i = interactor_with { input :n, numericality: true }
    expect(i.call(n: 1).success?).to be true
    expect(i.call(n: 1.5).success?).to be true
    expect(i.call(n: '42').success?).to be true
  end

  it 'fails for non-numeric values' do
    i = interactor_with { input :n, numericality: true }
    expect(i.call(n: 'abc').success?).to be false
    expect(i.call(n: []).success?).to be false
  end

  it 'only_integer rejects floats' do
    i = interactor_with { input :n, numericality: { only_integer: true } }
    expect(i.call(n: 3).success?).to be true
    expect(i.call(n: 3.5).success?).to be false
    expect(i.call(n: '3').success?).to be true
    expect(i.call(n: '3.5').success?).to be false
  end

  it 'odd: rejects even numbers' do
    i = interactor_with { input :n, numericality: { odd: true } }
    expect(i.call(n: 3).success?).to be true
    expect(i.call(n: 4).success?).to be false
  end

  it 'even: rejects odd numbers' do
    i = interactor_with { input :n, numericality: { even: true } }
    expect(i.call(n: 4).success?).to be true
    expect(i.call(n: 3).success?).to be false
  end

  it 'greater_than' do
    i = interactor_with { input :age, numericality: { greater_than: 0 } }
    expect(i.call(age: 1).success?).to be true
    expect(i.call(age: 0).success?).to be false
    expect(i.call(age: -1).success?).to be false
  end

  it 'less_than_or_equal_to' do
    i = interactor_with { input :score, numericality: { less_than_or_equal_to: 100 } }
    expect(i.call(score: 100).success?).to be true
    expect(i.call(score: 101).success?).to be false
  end

  it 'skips nil values' do
    i = interactor_with { input :n, numericality: { greater_than: 0 } }
    expect(i.call(n: nil).success?).to be true
  end

  it 'equal_to' do
    i = interactor_with { input :n, numericality: { equal_to: 42 } }
    expect(i.call(n: 42).success?).to be true
    expect(i.call(n: 41).success?).to be false
  end

  it 'other_than' do
    i = interactor_with { input :n, numericality: { other_than: 0 } }
    expect(i.call(n: 1).success?).to be true
    expect(i.call(n: 0).success?).to be false
  end

  it 'greater_than_or_equal_to' do
    i = interactor_with { input :n, numericality: { greater_than_or_equal_to: 5 } }
    expect(i.call(n: 5).success?).to be true
    expect(i.call(n: 4).success?).to be false
  end

  it 'less_than' do
    i = interactor_with { input :n, numericality: { less_than: 10 } }
    expect(i.call(n: 9).success?).to be true
    expect(i.call(n: 10).success?).to be false
  end

  it 'multiple constraints combined' do
    i = interactor_with { input :n, numericality: { greater_than: 0, less_than: 100 } }
    expect(i.call(n: 50).success?).to be true
    expect(i.call(n: 0).success?).to be false
    expect(i.call(n: 100).success?).to be false
  end

  it 'default message says is not a number for bare numericality:' do
    i = interactor_with { input :n, numericality: true }
    expect(i.call(n: 'abc').errors[:n].first).to match(/is not a number/)
  end

  it 'default message includes constraint description' do
    i = interactor_with { input :n, numericality: { greater_than: 0 } }
    expect(i.call(n: -1).errors[:n].first).to eq('Input param "n" must be greater than 0')
  end

  it 'supports custom message' do
    i = interactor_with { input :age, numericality: { greater_than: 0, message: 'must be positive' } }
    expect(i.call(age: -1).errors[:age].first).to eq('must be positive')
  end
end
