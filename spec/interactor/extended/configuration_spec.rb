# frozen_string_literal: true

RSpec.describe Interactor::Extended::Configuration do
  describe '#initialize' do
    it 'sets default values' do
      config = described_class.new
      expect(config.logger).to be_a(Logger)
      expect(config.type).to eq(:all)
      expect(config.duration_format).to eq(:color_string)
      expect(config.types).to be_a(Hash)
    end
  end

  describe '#add_type!' do
    it 'adds a new type' do
      config = described_class.new
      config.add_type!(:custom, [Object])
      expect(config.types[:custom]).to eq([Object])
    end

    it 'raises error when replacing existing type' do
      config = described_class.new
      expect { config.add_type!(:base, [Object]) }.to raise_error('Can\'t replace')
    end

    it 'inherits from another type' do
      config = described_class.new
      config.add_type!(:inherited, [Object], :base)
      expect(config.types[:inherited]).to eq(config.types[:base] + [Object])
    end
  end
end
