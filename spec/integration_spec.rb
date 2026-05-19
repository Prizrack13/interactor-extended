# frozen_string_literal: true

RSpec.describe 'Integration' do
  # organizer_a
  #  ├─ organizer_b
  #  │   ├─ interactor_b1
  #  │   ├─ interactor_b2
  #  ├─ interactor_c
  #  └─ interactor_d

  let(:organizer_a) { build_test_organizer(:a, organize: [organizer_b, interactor_c, interactor_d]) }
  let(:organizer_b) { build_test_organizer(:b, organize: [interactor_b1, interactor_b2]) }
  let(:interactor_b1) { build_test_interactor(:b1) }
  let(:interactor_b2) { build_test_interactor(:b2) }
  let(:interactor_c) { build_test_interactor(:c) }
  let(:interactor_d) { build_test_interactor(:d) }

  let(:context) { Interactor::LightContext.new(steps: []) }

  context 'when successful' do
    it 'calls and runs hooks in the proper sequence' do
      to = %i[
        around_before_a before_a call_a
        around_before_b before_b call_b
        around_before_b1 before_b1 call_b1 after_b1 around_after_b1
        around_before_b2 before_b2 call_b2 after_b2 around_after_b2
        after_b around_after_b
        around_before_c before_c call_c after_c around_after_c
        around_before_d before_d call_d after_d around_after_d
        after_a around_after_a
      ]
      organizer_a.call(context)
      # p context[:steps].join(' ')
      expect(context[:steps]).to eq(to)
    end
  end

  context 'when failed' do
    let(:interactor_c) { build_test_interactor(:c) { define_method(:call) { context.fail!(error: 'test') } } }

    it 'calls and runs hooks in the proper sequence' do
      to = %i[
        around_before_a before_a call_a
        around_before_b before_b call_b
        around_before_b1 before_b1 call_b1 after_b1 around_after_b1
        around_before_b2 before_b2 call_b2 after_b2 around_after_b2
        after_b around_after_b
        around_before_c before_c
        rollback_b rollback_b2 rollback_b1
      ]
      organizer_a.call(context)
      # p context[:steps].join(' ')
      expect(context[:steps]).to eq(to)
    end
  end
end
