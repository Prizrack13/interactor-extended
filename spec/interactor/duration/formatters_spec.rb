# frozen_string_literal: true

RSpec.describe Interactor::Duration::BaseFormatter do
  let(:sample_data) do
    [
      ['Interactor::A', [
        ['Interactor::B', [], 1000.0, 1050.0, 50.0]
      ], 1000.0, 1100.0, 50.0],
      ['Interactor::A', [], 1200.0, 1300.0, 100.0]
    ]
  end

  describe '.value' do
    around do |example|
      original_format = Interactor::Extended.configuration.duration_format
      example.run
      Interactor::Extended.configuration.duration_format = original_format
    end

    it 'selects ColorStringFormatter by default' do
      Interactor::Extended.configuration.duration_format = :color_string
      result = described_class.value(sample_data)
      expect(result).to be_a(String)
      expect(result).to include("\e[")
    end

    it 'selects StringFormatter for :string format' do
      Interactor::Extended.configuration.duration_format = :string
      result = described_class.value(sample_data)
      expect(result).to be_a(String)
      expect(result).not_to include("\e[")
    end

    it 'selects JsonFormatter for :json format' do
      Interactor::Extended.configuration.duration_format = :json
      result = described_class.value(sample_data)
      expect(result).to be_an(Array)
      expect(result.first).to include(:name, :count, :time, :own, :max)
    end

    it 'selects flat json for :flat_json format' do
      Interactor::Extended.configuration.duration_format = :flat_json
      result = described_class.value(sample_data)
      expect(result).to be_an(Array)
      expect(result.none? { |r| r.key?(:children) }).to be true
    end

    it 'selects flat string for :flat_string format' do
      Interactor::Extended.configuration.duration_format = :flat_string
      result = described_class.value(sample_data)
      expect(result).to be_a(String)
    end
  end

  describe '#value' do
    it 'returns the raw duration data' do
      formatter = described_class.new(sample_data)
      expect(formatter.value).to be(sample_data)
    end

    it 'accepts options hash' do
      formatter = described_class.new(sample_data, flat: true)
      expect(formatter.value).to be(sample_data)
    end
  end
end

RSpec.describe Interactor::Duration::JsonFormatter do
  let(:sample_data) do
    [
      ['Interactor::A', [
        ['Interactor::B', [], 1000.0, 1050.0, 50.0]
      ], 1000.0, 1100.0, 50.0],
      ['Interactor::A', [], 1200.0, 1300.0, 100.0]
    ]
  end

  describe '#value' do
    it 'groups repeated names and computes averages' do
      result = described_class.new(sample_data).value
      expect(result.length).to eq(1)
      node = result.first
      expect(node[:name]).to eq('Interactor::A')
      expect(node[:count]).to eq(2)
      expect(node[:level]).to eq(0)
      expect(node[:time]).to be_a(Float)
      expect(node[:own]).to be_a(Float)
    end

    it 'includes children nodes' do
      result = described_class.new(sample_data).value
      children = result.first[:children]
      expect(children.length).to eq(1)
      expect(children.first[:name]).to eq('Interactor::B')
      expect(children.first[:level]).to eq(1)
    end

    it 'returns flat array when flat: true' do
      result = described_class.new(sample_data, flat: true).value
      expect(result).to be_an(Array)
      result.each { |r| expect(r).not_to have_key(:children) }
    end

    it 'handles empty data' do
      result = described_class.new([]).value
      expect(result).to eq([])
    end
  end
end

RSpec.describe Interactor::Duration::StringFormatter do
  let(:sample_data) do
    [
      ['Interactor::A', [
        ['Interactor::B', [], 1000.0, 1050.0, 50.0]
      ], 1000.0, 1100.0, 50.0]
    ]
  end

  describe '#value' do
    it 'returns a String' do
      result = described_class.new(sample_data).value
      expect(result).to be_a(String)
    end

    it 'includes node names' do
      result = described_class.new(sample_data).value
      expect(result).to include('Interactor::A')
      expect(result).to include('Interactor::B')
    end

    it 'includes count and time stats' do
      result = described_class.new(sample_data).value
      expect(result).to include('count:')
      expect(result).to include('time:')
      expect(result).to include('own:')
      expect(result).to include('max:')
    end

    it 'returns a flat string when flat: true' do
      result = described_class.new(sample_data, flat: true).value
      expect(result).to be_a(String)
      expect(result).to include('Interactor::A')
    end

    it 'handles empty data' do
      result = described_class.new([]).value
      expect(result).to be_a(String)
    end
  end
end

RSpec.describe Interactor::Duration::ColorStringFormatter do
  let(:sample_data) do
    [
      ['Interactor::A', [
        ['Interactor::B', [], 1000.0, 1050.0, 50.0]
      ], 1000.0, 1100.0, 50.0]
    ]
  end

  describe '#value' do
    it 'returns a String with ANSI color codes' do
      result = described_class.new(sample_data).value
      expect(result).to be_a(String)
      expect(result).to include("\e[")
    end

    it 'includes node names' do
      result = described_class.new(sample_data).value
      expect(result).to include('Interactor::A')
      expect(result).to include('Interactor::B')
    end
  end
end
