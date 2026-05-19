# frozen_string_literal: true

RSpec.describe Interactor::Extended do
  it 'has a version number' do
    expect(Interactor::Extended::VERSION).not_to be nil
  end

  it 'has a version method' do
    expect(Interactor::Extended.version).to eq Interactor::Extended::VERSION
  end

  describe '.configuration' do
    it 'returns a Configuration instance' do
      expect(described_class.configuration).to be_a(Interactor::Extended::Configuration)
    end

    it 'returns the same instance each time' do
      expect(described_class.configuration).to be(described_class.configuration)
    end
  end

  describe '.configuration=' do
    around do |example|
      original = described_class.configuration
      example.run
      described_class.configuration = original
    end

    it 'replaces the configuration' do
      new_config = Interactor::Extended::Configuration.new
      described_class.configuration = new_config
      expect(described_class.configuration).to be(new_config)
    end
  end

  describe '.configure' do
    around do |example|
      original_type = described_class.configuration.type
      example.run
      described_class.configuration.type = original_type
    end

    it 'yields the configuration object' do
      described_class.configure { |c| c.type = :light }
      expect(described_class.configuration.type).to eq(:light)
    end
  end

  describe '.modules' do
    it 'returns Organizer for :flow kind' do
      result = described_class.modules(:flow, :base)
      expect(result).to include(Interactor::Organizer)
    end

    it 'returns Interactor for :operation kind' do
      result = described_class.modules(:operation, :base)
      expect(result).to include(Interactor)
    end

    it 'accepts an Array type directly' do
      mod = Module.new
      result = described_class.modules(:operation, [mod])
      expect(result).to include(mod)
    end
  end

  describe '.build_module' do
    it 'returns a Module' do
      expect(described_class.build_module(:operation, :all)).to be_a(Module)
    end

    it 'caches the result for the same kind+type' do
      m1 = described_class.build_module(:operation, :ctx)
      m2 = described_class.build_module(:operation, :ctx)
      expect(m1).to be(m2)
    end

    it 'returns different modules for different types' do
      expect(described_class.build_module(:operation, :all)).not_to \
        be(described_class.build_module(:operation, :light))
    end
  end

  describe '.thread' do
    it 'returns a Thread' do
      t = described_class.thread { nil }
      expect(t).to be_a(Thread)
      t.join
    end

    it 'executes the block in a separate thread' do
      ids = []
      t = described_class.thread { ids << Thread.current.object_id }
      t.join
      expect(ids.first).not_to eq(Thread.current.object_id)
    end
  end
end
