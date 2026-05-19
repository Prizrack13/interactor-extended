# frozen_string_literal: true

RSpec.describe Interactor::Organize do
  let(:interactor) do
    build_interactor do
      def call
        context[:a] = 1
      end
    end
  end
  let(:interactor2) do
    build_interactor do
      def call
        context[:b] = 2
      end
    end
  end
  let(:organizer) { build_organizer(organize: [interactor, interactor2]) }

  it 'organizes the interactor' do
    expect(organizer.call!(c: 3).to_h).to eq({ a: 1, b: 2, c: 3 })
  end

  it 'organizes organized' do
    expect(organizer.call!(organized: [interactor]).to_h).to eq({ a: 1, organized: [interactor] })
  end

  describe '.thread' do
    it 'returns a ThreadRunner' do
      runner = organizer.thread(interactor)
      expect(runner).to be_a(Interactor::Organize::ThreadRunner)
    end

    it 'executes the klass in a separate thread via call!' do
      context = Interactor::LightContext.new
      runner = organizer.thread(interactor)
      thread = runner.call(context)
      expect(thread).to be_a(Thread)
      thread.join
      expect(context[:a]).to eq(1)
    end
  end

  describe 'nested organizer' do
    let(:inner_organizer) { build_organizer(organize: [interactor]) }
    let(:outer_organizer) { build_organizer(organize: [inner_organizer, interactor2]) }

    it 'executes nested organizers in order' do
      result = outer_organizer.call!
      expect(result[:a]).to eq(1)
      expect(result[:b]).to eq(2)
    end
  end

  describe 'failure in organized interactor' do
    let(:failing) do
      build_interactor do
        def call
          context.fail!(error: 'boom')
        end
      end
    end
    let(:organizer) { build_organizer(organize: [interactor, failing, interactor2]) }

    it 'stops execution and propagates the failure' do
      result = organizer.call
      expect(result.failure?).to be true
      expect(result[:error]).to eq('boom')
      expect(result[:b]).to be_nil
    end
  end
end
