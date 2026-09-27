# frozen_string_literal: true

RSpec.describe Interactor::Validations::Type do
  describe 'array: true' do
    it 'accepts array of the declared type' do
      i = interactor_with { input :tags, String, array: true }
      expect(i.call(tags: %w[a b]).success?).to be true
      expect(i.call(tags: ['a', 1]).success?).to be false
      expect(i.call(tags: 'flat').success?).to be false
    end

    it 'skips nil' do
      i = interactor_with { input :tags, String, array: true }
      expect(i.call(tags: nil).success?).to be true
    end

    it '[Integer, Float], array: true means array of Integer or Float' do
      i = interactor_with { input :nums, [Integer, Float], array: true }
      expect(i.call(nums: [1, 2.5]).success?).to be true
      expect(i.call(nums: [1, 'x']).success?).to be false
    end
  end

  describe 'union type' do
    it '[Integer, Float] without array: accepts either type' do
      i = interactor_with { input :n, [Integer, Float] }
      expect(i.call(n: 3).success?).to be true
      expect(i.call(n: 3.14).success?).to be true
      expect(i.call(n: '3').success?).to be false
    end
  end

  describe 'single type' do
    it 'passes for matching type' do
      i = interactor_with { input :name, String }
      expect(i.call(name: 'hello').success?).to be true
    end

    it 'fails for wrong type' do
      i = interactor_with { input :name, String }
      expect(i.call(name: 42).success?).to be false
    end

    it 'skips nil' do
      i = interactor_with { input :name, String }
      expect(i.call(name: nil).success?).to be true
    end

    it 'error message names the type and param' do
      i = interactor_with { input :count, Integer }
      expect(i.call(count: 'x').errors[:count].first).to eq('Input param "count" is not kind of Integer')
    end

    it 'supports custom message' do
      i = interactor_with { input :count, type: { with: Integer, message: 'must be an integer' } }
      expect(i.call(count: 'x').errors[:count].first).to eq('must be an integer')
    end
  end

  describe ':boolean type' do
    it 'accepts true and false' do
      i = interactor_with { input :flag, :boolean }
      expect(i.call(flag: true).success?).to be true
      expect(i.call(flag: false).success?).to be true
    end

    it 'rejects non-boolean values' do
      i = interactor_with { input :flag, :boolean }
      expect(i.call(flag: 1).success?).to be false
      expect(i.call(flag: 'true').success?).to be false
      expect(i.call(flag: nil).success?).to be true
    end
  end

  describe 'empty array with array: true' do
    it 'passes (vacuously valid)' do
      i = interactor_with { input :tags, String, array: true }
      expect(i.call(tags: []).success?).to be true
    end
  end
end
