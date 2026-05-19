# frozen_string_literal: true

RSpec.describe Interactor::Colorize do
  subject { described_class }

  describe '.colorize' do
    it 'print correct colors' do
      # described_class.singleton_class::MODES.each_key do |mode|
      #   described_class.singleton_class::COLORS.each_key do |color|
      #     described_class.singleton_class::COLORS.each_key do |bg|
      #       print described_class::colorize('m', color, mode: mode, bg: bg)
      #     end
      #   end
      # end
      expect(described_class.colorize('msg', :red)).to eq("\e[1;31;49mmsg\e[0m")
    end

    it 'applies color via keyword arg' do
      expect(described_class.colorize('hi', color: :green)).to include("\e[")
      expect(described_class.colorize('hi', color: :green)).to include('hi')
    end

    it 'applies mode' do
      expect(described_class.colorize('hi', mode: :dim)).to start_with("\e[2;")
    end

    it 'applies background color' do
      result = described_class.colorize('hi', :red, bg: :blue)
      expect(result).to include(';44m')
    end

    it 'defaults to bold mode when no mode given' do
      result = described_class.colorize('hi', :red)
      expect(result).to start_with("\e[1;")
    end

    it 'defaults to default color when nil positional color given' do
      result = described_class.colorize('hi', nil)
      expect(result).to include(';39;')
    end

    it 'wraps message with reset sequence' do
      result = described_class.colorize('hi')
      expect(result).to end_with("\e[0m")
    end
  end

  describe '#colorize instance method' do
    let(:klass) do
      Class.new.tap { _1.include(described_class) }.new
    end

    it 'delegates to Colorize.colorize' do
      expect(klass.colorize('msg', :red)).to eq(described_class.colorize('msg', :red))
    end
  end
end
