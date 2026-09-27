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
    it 'returns a hash entry with thread: true' do
      expect(organizer.thread(interactor)).to eq({ class: interactor, thread: true })
    end

    it 'merges extra options into the hash' do
      expect(organizer.thread(interactor, if: :yes?)).to eq({ class: interactor, thread: true, if: :yes? })
    end

    context 'multiple threads in organize' do
      let(:threaded_organizer) do
        i1 = interactor
        i2 = interactor2
        build_organizer do
          organize thread(i1), thread(i2)
        end
      end

      it 'starts all threads and joins them before returning' do
        result = threaded_organizer.call!
        expect(result[:a]).to eq(1)
        expect(result[:b]).to eq(2)
      end
    end

    context 'with condition' do
      let(:threaded_organizer) do
        i1 = interactor
        build_organizer do
          organize thread(i1, if: :run_threaded?)
          def run_threaded? = context[:run_threaded]
        end
      end

      it 'executes the thread when condition is true' do
        result = threaded_organizer.call!(run_threaded: true)
        expect(result[:a]).to eq(1)
      end

      it 'skips the thread when condition is false' do
        result = threaded_organizer.call!(run_threaded: false)
        expect(result[:a]).to be_nil
      end
    end
  end

  describe 'inheritance' do
    it 'uses parent organized when child has none' do
      child = Class.new(organizer)
      expect(child.organized).to eq(organizer.organized)
    end

    it 'uses own organized when child defines its own' do
      child = Class.new(organizer)
      child.organize([interactor])
      expect(child.call!.to_h).to eq({ a: 1 })
      expect(organizer.call!.to_h).to eq({ a: 1, b: 2 })
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

  describe 'conditional organize' do
    let(:organizer) do
      build_organizer(organize: [interactor, { class: interactor2, if: :run_second? }]) do
        def run_second?
          context[:run_second]
        end
      end
    end

    it 'runs the conditional interactor when :if condition is true' do
      result = organizer.call!(run_second: true)
      expect(result[:a]).to eq(1)
      expect(result[:b]).to eq(2)
    end

    it 'skips the conditional interactor when :if condition is false' do
      result = organizer.call!(run_second: false)
      expect(result[:a]).to eq(1)
      expect(result[:b]).to be_nil
    end

    it 'skips the conditional interactor when :if condition is absent (falsy)' do
      result = organizer.call!
      expect(result[:a]).to eq(1)
      expect(result[:b]).to be_nil
    end

    context 'with :unless condition' do
      let(:organizer) do
        build_organizer(organize: [interactor, { class: interactor2, unless: :skip_second? }]) do
          def skip_second?
            context[:skip_second]
          end
        end
      end

      it 'runs the interactor when :unless condition is false' do
        result = organizer.call!(skip_second: false)
        expect(result[:a]).to eq(1)
        expect(result[:b]).to eq(2)
      end

      it 'skips the interactor when :unless condition is true' do
        result = organizer.call!(skip_second: true)
        expect(result[:a]).to eq(1)
        expect(result[:b]).to be_nil
      end
    end

    context 'with plain hash { class: X } (no condition)' do
      let(:organizer) { build_organizer(organize: [interactor, { class: interactor2 }]) }

      it 'always runs the interactor' do
        result = organizer.call!
        expect(result[:a]).to eq(1)
        expect(result[:b]).to eq(2)
      end
    end

    context 'with Proc condition' do
      let(:organizer) do
        build_organizer(organize: [interactor, { class: interactor2, if: -> { context[:run_second] } }])
      end

      it 'runs when proc returns true' do
        result = organizer.call!(run_second: true)
        expect(result[:b]).to eq(2)
      end

      it 'skips when proc returns false' do
        result = organizer.call!(run_second: false)
        expect(result[:b]).to be_nil
      end
    end

    context 'with pair shorthand: Class, {if:} trailing hash' do
      let(:organizer) do
        i1 = interactor
        i2 = interactor2
        build_organizer do
          organize i1, { if: :run_first? }, i2
          def run_first?
            context[:run_first]
          end
        end
      end

      it 'runs the paired interactor when condition is true' do
        result = organizer.call!(run_first: true)
        expect(result[:a]).to eq(1)
        expect(result[:b]).to eq(2)
      end

      it 'skips the paired interactor when condition is false' do
        result = organizer.call!(run_first: false)
        expect(result[:a]).to be_nil
        expect(result[:b]).to eq(2)
      end
    end

    context 'with step helper' do
      let(:organizer) do
        i1 = interactor
        i2 = interactor2
        build_organizer do
          organize step(i1, if: :run_first?), step(i2, unless: :skip_second?)
          def run_first? = context[:run_first]
          def skip_second? = context[:skip_second]
        end
      end

      it 'runs both when conditions allow' do
        result = organizer.call!(run_first: true, skip_second: false)
        expect(result[:a]).to eq(1)
        expect(result[:b]).to eq(2)
      end

      it 'skips first when :if is false' do
        result = organizer.call!(run_first: false, skip_second: false)
        expect(result[:a]).to be_nil
        expect(result[:b]).to eq(2)
      end

      it 'skips second when :unless is true' do
        result = organizer.call!(run_first: true, skip_second: true)
        expect(result[:a]).to eq(1)
        expect(result[:b]).to be_nil
      end
    end
  end

  describe 'symbol class — organize :method_name' do
    let(:organizer) do
      i1 = interactor
      i2 = interactor2
      build_organizer do
        organize :step_one, :step_two
        define_method(:step_one) { i1.call!(context) }
        define_method(:step_two) { i2.call!(context) }
      end
    end

    it 'calls each method on the organizer instance in order' do
      result = organizer.call!
      expect(result[:a]).to eq(1)
      expect(result[:b]).to eq(2)
    end

    context 'with pair shorthand: :symbol, {if:} trailing hash' do
      let(:organizer) do
        i1 = interactor
        i2 = interactor2
        build_organizer do
          organize :step_one, { if: :run_first? }, :step_two
          define_method(:step_one) { i1.call!(context) }
          define_method(:step_two) { i2.call!(context) }
          def run_first? = context[:run_first]
        end
      end

      it 'runs the method when condition is true' do
        result = organizer.call!(run_first: true)
        expect(result[:a]).to eq(1)
        expect(result[:b]).to eq(2)
      end

      it 'skips the method when condition is false' do
        result = organizer.call!(run_first: false)
        expect(result[:a]).to be_nil
        expect(result[:b]).to eq(2)
      end
    end

    context 'with explicit hash form { class: :method_name }' do
      let(:organizer) do
        i1 = interactor
        build_organizer do
          organize({ class: :step_one })
          define_method(:step_one) { i1.call!(context) }
        end
      end

      it 'calls the named method' do
        expect(organizer.call![:a]).to eq(1)
      end
    end

    context 'with step helper' do
      let(:organizer) do
        i1 = interactor
        i2 = interactor2
        build_organizer do
          organize step(:step_one, if: :run_first?), step(:step_two, unless: :skip_second?)
          define_method(:step_one) { i1.call!(context) }
          define_method(:step_two) { i2.call!(context) }
          def run_first?   = context[:run_first]
          def skip_second? = context[:skip_second]
        end
      end

      it 'respects :if on a symbol step' do
        result = organizer.call!(run_first: false, skip_second: false)
        expect(result[:a]).to be_nil
        expect(result[:b]).to eq(2)
      end

      it 'respects :unless on a symbol step' do
        result = organizer.call!(run_first: true, skip_second: true)
        expect(result[:a]).to eq(1)
        expect(result[:b]).to be_nil
      end
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
