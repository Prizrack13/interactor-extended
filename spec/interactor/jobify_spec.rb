# frozen_string_literal: true

RSpec.describe Interactor::Jobify do
  let(:interactor) do
    build_interactor(Interactor::Operation) do
      jobify

      def call; end
    end
  end

  it 'perform_later' do
    expect_any_instance_of(interactor).to receive(:perform_later).with({ 'a' => 1, 'jobify' => true })
    interactor.call!(a: 1, jobify: true)
  end

  it 'perform_in' do
    expect_any_instance_of(interactor).to receive(:perform_in).with(30, { 'a' => 1, 'jobify' => 30 })
    interactor.call!(a: 1, jobify: 30)
  end

  describe 'default: true' do
    let(:interactor) do
      build_interactor(Interactor::Operation) do
        jobify default: true
        def call; end
      end
    end

    it 'performs as a job without explicit jobify context key' do
      expect_any_instance_of(interactor).to receive(:perform_later)
      interactor.call!
    end
  end

  describe 'jobify disabled via context' do
    it 'runs inline when context[:jobify] is false' do
      expect_any_instance_of(interactor).not_to receive(:perform_later)
      expect_any_instance_of(interactor).not_to receive(:perform_in)
      interactor.call!(jobify: false)
    end
  end

  describe 'custom job class' do
    let(:job_class) { double('JobClass') }

    let(:interactor) do
      klass = job_class
      build_interactor(Interactor::Operation) do
        jobify(klass:)
        def call; end
      end
    end

    it 'uses the provided klass' do
      expect(job_class).to receive(:perform_later)
      interactor.call!(jobify: true)
    end
  end

  describe 'params as Proc' do
    let(:interactor) do
      build_interactor(Interactor::Operation) do
        jobify params: ->(_i) { { custom: true } }
        def call; end
      end
    end

    it 'uses the proc return value as job args' do
      expect_any_instance_of(interactor).to receive(:perform_later).with({ 'custom' => true })
      interactor.call!(jobify: true)
    end
  end

  describe 'params as block' do
    let(:interactor) do
      build_interactor(Interactor::Operation) do
        jobify { |_i| { from_block: true } }
        def call; end
      end
    end

    it 'uses the block return value as job args' do
      expect_any_instance_of(interactor).to receive(:perform_later).with({ 'from_block' => true })
      interactor.call!(jobify: true)
    end
  end

  describe '.job_active' do
    it 'is nil when jobify has not been called' do
      plain = build_interactor(Interactor::Operation) { def call; end }
      expect(plain.job_active).to be_nil
    end

    it 'is true when jobify has been called' do
      expect(interactor.job_active).to be true
    end
  end
end
