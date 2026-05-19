# frozen_string_literal: true

RSpec.describe Interactor::Threadable do
  let(:klass) { Class.new.tap { |c| c.include(described_class) }.new }

  describe '#thread' do
    it 'returns a Thread' do
      t = klass.thread { nil }
      expect(t).to be_a(Thread)
      t.join
    end

    it 'executes the block in the new thread' do
      result = []
      t = klass.thread { result << Thread.current.object_id }
      t.join
      expect(result).not_to be_empty
      expect(result.first).not_to eq(Thread.current.object_id)
    end

    it 'executes the block asynchronously' do
      barrier = Queue.new
      t = klass.thread { barrier.pop }
      expect(t.alive?).to be true
      barrier.push(:go)
      t.join
      expect(t.alive?).to be false
    end
  end
end
