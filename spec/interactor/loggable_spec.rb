# frozen_string_literal: true

RSpec.describe Interactor::Loggable do
  let(:interactor) { build_interactor }
  it 'return logger' do
    expect(interactor.logger).to be_a(Logger)
  end
end
