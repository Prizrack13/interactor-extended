# frozen_string_literal: true

RSpec.describe Interactor::Validations::Required do
  it 'fails for nil' do
    i = interactor_with { input :id, required: true }
    expect(i.call(id: nil).success?).to be false
  end

  it 'passes for any non-nil value' do
    i = interactor_with { input :id, required: true }
    expect(i.call(id: 0).success?).to be true
    expect(i.call(id: false).success?).to be true
    expect(i.call(id: '').success?).to be true
    expect(i.call(id: []).success?).to be true
  end

  it 'message includes param label' do
    i = interactor_with { input :name, required: true }
    expect(i.call(name: nil).errors[:name].first).to eq('Input param "name" is required')
  end

  it 'supports output direction in message' do
    i = interactor_with { output :token, required: true }
    expect(i.call(token: nil).errors[:token].first).to eq('Output param "token" is required')
  end

  it 'supports custom message via hash form' do
    i = interactor_with { input :id, required: { message: 'must be present' } }
    expect(i.call(id: nil).errors[:id].first).to eq('must be present')
  end

  it 'supports custom message in validations: array' do
    i = interactor_with { input :id, validations: [{ required: true, message: 'id is required' }] }
    expect(i.call(id: nil).errors[:id].first).to eq('id is required')
  end
end
