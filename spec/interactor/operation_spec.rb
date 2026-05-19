# frozen_string_literal: true

RSpec.describe Interactor::Operation do
  describe '.[]' do
    it 'returns a Module' do
      expect(described_class[:all]).to be_a(Module)
    end

    it 'returns the same cached module on repeated calls' do
      mod1 = described_class[:all]
      mod2 = described_class[:all]
      expect(mod1).to be(mod2)
    end

    it 'returns distinct modules for different types' do
      expect(described_class[:all]).not_to be(described_class[:light])
    end

    it 'includes Interactor when included into a class' do
      klass = Class.new
      klass.include(described_class[:all])
      expect(klass.ancestors).to include(Interactor)
    end
  end

  describe '.included' do
    it 'includes the configured operation modules into the base class' do
      klass = Class.new
      klass.include(described_class)
      expect(klass.ancestors).to include(Interactor)
    end
  end
end
