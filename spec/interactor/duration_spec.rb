# frozen_string_literal: true

RSpec.describe Interactor::Duration do
  let(:interactor) do
    build_interactor(Interactor::Operation[:all_debug]) do
      def call
        sleep 0.1
      end
    end
  end
  let(:interactor2) do
    build_interactor(Interactor::Operation[:all_debug]) do
      def call
        sleep 0.2
      end
    end
  end
  let(:interactor3) do
    build_interactor(Interactor::Operation[:all_debug]) do
      duration(true)
      def call
        another
        sleep 0.1
      end

      def another
        sleep 0.1
      end
    end
  end
  let(:interactor4) do
    build_interactor(Interactor::Operation[:all_debug]) do
      duration
      def call
        another
        sleep 0.1
      end

      def another
        sleep 0.1
      end
    end
  end
  let(:organizer) { build_organizer({ organize: [interactor, interactor2] }, Interactor::Flow[:all_debug]) }
  let(:messages) { [] }

  before do
    Interactor::Extended.configure do |c|
      c.duration_format = :json
      c.on_duration = ->(message) { messages << message }
    end
  end

  it 'calls and runs hooks in the proper sequence' do
    organizer.call!
    expect(messages.first.count).to eq(1)
    message = messages.first[0]
    child_message = messages.first.dig(0, :children, 0)
    expect(message[:name]).to eq('Anonymous::Interactor::Flow')
    expect(message[:count]).to eq(1)
    expect(message[:time] > 300).to eq(true)
    expect(message[:own] < 100).to eq(true)
    expect(message[:max] < 100).to eq(true)
    expect(child_message[:name]).to eq('Anonymous::Interactor::Operation')
    expect(child_message[:count]).to eq(2)
    expect(child_message[:time] > 150).to eq(true)
    expect(child_message[:time] < 190).to eq(true)
    expect(child_message[:own] > 150).to eq(true)
    expect(child_message[:own] < 190).to eq(true)
    expect(child_message[:max] > 200).to eq(true)
  end

  it 'inherit' do
    Class.new(interactor).call!
    expect(messages.count).to eq(1)
  end

  it 'duration' do
    interactor3.call!
    message = messages.first[0]
    child_message = messages.first.dig(0, :children, 0)
    child_message2 = messages.first.dig(0, :children, 0, :children, 0)
    expect(messages.first.count).to eq(1)
    expect(message[:name]).to eq('Anonymous::Interactor::Operation')
    expect(message[:count]).to eq(1)
    expect(message[:time] > 200).to eq(true)
    expect(message[:own] < 10).to eq(true)
    expect(message[:max] < 10).to eq(true)
    expect(child_message[:name]).to eq('Anonymous::Interactor::Operation#call')
    expect(child_message[:count]).to eq(1)
    expect(child_message[:time] > 200).to eq(true)
    expect(child_message[:own] > 100).to eq(true)
    expect(child_message[:own] < 200).to eq(true)
    expect(child_message[:max] > 100).to eq(true)
    expect(child_message2[:name]).to eq('Anonymous::Interactor::Operation#another')
    expect(child_message2[:count]).to eq(1)
    expect(child_message2[:time] < 200).to eq(true)
    expect(child_message2[:own] < 200).to eq(true)
    expect(child_message2[:max] < 200).to eq(true)
  end

  it 'duration(all)' do
    interactor4.call!
    message = messages.first[0]
    child_message = messages.first.dig(0, :children, 0)
    expect(messages.first.count).to eq(1)
    expect(message[:name]).to eq('Anonymous::Interactor::Operation')
    expect(message[:count]).to eq(1)
    expect(message[:time] > 200).to eq(true)
    expect(message[:own] < 10).to eq(true)
    expect(message[:max] < 10).to eq(true)
    expect(child_message[:name]).to eq('Anonymous::Interactor::Operation#call')
    expect(child_message[:count]).to eq(1)
    expect(child_message[:time] > 200).to eq(true)
    expect(child_message[:own] > 200).to eq(true)
    expect(child_message[:max] > 200).to eq(true)
  end

  context 'string format' do
    before { Interactor::Extended.configure { _1.duration_format = :string } }

    it 'calls on_duration with a String' do
      organizer.call!
      expect(messages.first).to be_a(String)
      expect(messages.first).to include('Anonymous::Interactor::Flow')
    end
  end

  context 'color_string format' do
    before { Interactor::Extended.configure { _1.duration_format = :color_string } }

    it 'calls on_duration with a colorized String' do
      organizer.call!
      expect(messages.first).to be_a(String)
      expect(messages.first).to include("\e[")
    end
  end

  context 'flat_json format' do
    before { Interactor::Extended.configure { _1.duration_format = :flat_json } }

    it 'calls on_duration with a flat Array of hashes without :children' do
      organizer.call!
      expect(messages.first).to be_an(Array)
      messages.first.each { |m| expect(m).not_to have_key(:children) }
    end
  end

  context 'flat_string format' do
    before { Interactor::Extended.configure { _1.duration_format = :flat_string } }

    it 'calls on_duration with a flat String' do
      organizer.call!
      expect(messages.first).to be_a(String)
    end
  end
end
