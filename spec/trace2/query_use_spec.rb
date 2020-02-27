# frozen_string_literal: true

require 'spec_helper'

describe QueryUse do
  describe '.reject' do
    it 'returns QueryUse with classes_uses' do
      classes_uses = [double('ClassUse')]

      query = QueryUse.reject(classes_uses)

      expect(query.classes_uses).to eq classes_uses
    end
  end

  describe '#reject' do
    it 'changes query action' do
      classes_uses = [double('ClassUse')]
      query = QueryUse.new(classes_uses, :select)

      new_query = query.reject

      expect(new_query.instance_variable_get(:@action)).to eq :reject
    end
  end

  describe '.allow' do
    it 'returns QueryUse with classes_uses' do
      classes_uses = [double('ClassUse')]

      query = QueryUse.allow(classes_uses)

      expect(query.classes_uses).to eq classes_uses
    end
  end

  describe '#allow' do
    it 'changes query action' do
      classes_uses = [double('ClassUse')]
      query = QueryUse.new(classes_uses, :select)

      new_query = query.allow

      expect(new_query.instance_variable_get(:@action)).to eq :select
    end
  end

  describe '#where' do
    it 'calls methods depending on input hash keys' do
      class_use = double('ClassUse')
      classes_uses = [class_use]
      query = QueryUse.reject(classes_uses)
      hash = { path: 'my_path', class_name: 'my_class' }

      expect(query).to receive(:path).with(class_use, 'my_path')
      expect(query).to receive(:class_name).with(class_use, 'my_class')
      query.where(hash)
    end

    it 'ignores queries with methods that were not implemented' do
      classes_uses = [double('ClassUse')]
      query = QueryUse.reject(classes_uses)
      hash = { not_implemented: 'not_implemented' }

      expect { query.where(hash) }.not_to raise_error
    end

    it 'returns the query as result' do
      classes_uses = [double('ClassUse', path: 'my_path')]
      query = QueryUse.allow(classes_uses)
      hash = { path: ['my_path'] }

      query_output = query.where(hash)

      expect(query_output).to eq query
    end

    context 'query by path' do
      it 'for a single path' do
        gem_class = double('ClassUse', path: 'gem/my/gem')
        not_gem_class = double('ClassUse', path: 'not/a/gem')

        classes_uses = [gem_class, not_gem_class]
        query = QueryUse.reject(classes_uses)

        hash = { path: ['gem/'] }
        query.where(hash)

        expect(query.classes_uses).to eq [not_gem_class]
      end

      it 'for multiple paths' do
        gem_class = double('ClassUse', path: 'gem/my/gem')
        not_gem_class = double('ClassUse', path: 'not/a/gem')
        controller_class = double('ClassUse', path: 'app/controllers')
        lib_class = double('ClassUse', path: 'lib/my/class')

        classes_uses = [
          gem_class, not_gem_class, controller_class, lib_class
        ]
        query = QueryUse.allow(classes_uses)

        hash = { path: ['gem/', 'app/'] }
        query.where(hash)

        expect(query.classes_uses).to eq [gem_class, controller_class]
      end
    end

    context 'query by class name' do
      it 'for a single class name' do
        rspec_class = double('ClassUse', name: 'RSpec')
        project_class = double('ClassUse', name: 'Project')

        classes_uses = [rspec_class, project_class]
        query = QueryUse.allow(classes_uses)

        hash = { class_name: ['Project'] }
        query.where(hash)

        expect(query.classes_uses).to eq [project_class]
      end

      it 'for multiple classes names' do
        rspec_class = double('ClassUse', name: 'RSpec')
        kaminari_class = double('ClassUse', name: 'Kaminari')
        module_class = double('ClassUse', name: 'My::Project')
        project_class = double('ClassUse', name: 'Project')

        classes_uses = [
          rspec_class, project_class, module_class, kaminari_class
        ]
        query = QueryUse.allow(classes_uses)

        hash = { class_name: %w[Project RSpec] }
        query.where(hash)

        expect(query.classes_uses).to eq [
          rspec_class, project_class, module_class
        ]
      end
    end

    context 'query by method name' do
      it 'for a one method' do
        it_method = double('ClassUse', method: 'it')
        describe_method = double('ClassUse', method: 'describe')

        classes_uses = [it_method, describe_method]
        query = QueryUse.allow(classes_uses)

        hash = { method: ['it'] }
        query.where(hash)

        expect(query.classes_uses).to eq [it_method]
      end

      it 'for multiple classes names' do
        it_method = double('ClassUse', method: 'it')
        describe_method = double('ClassUse', method: 'describe')
        run_method = double('ClassUse', method: 'run')

        classes_uses = [
          it_method, describe_method, run_method
        ]
        query = QueryUse.allow(classes_uses)

        hash = { method: %w[it run] }
        query.where(hash)

        expect(query.classes_uses).to eq [
          it_method, run_method
        ]
      end
    end

    context 'for multiple queries' do
      it 'works succesfully' do
        right_class = double('ClassUse', method: 'it', name: 'Rspec')
        wrong_name = double('ClassUse', method: 'it', name: 'NotMyClass')
        wrong_method = double('ClassUse', method: 'allow', name: 'Rspec')

        hash = { method: ['it'], class_name: ['Rspec'] }
        classes_uses = [right_class, wrong_method, wrong_name]

        query = QueryUse.allow(classes_uses)
        query.where(hash)

        expect(query.classes_uses).to eq [right_class]
      end
    end

    context 'query by caller' do
      it 'queries a direct caller using the where format' do
        caller_class = double(
          'ClassUse',
          method: 'it',
          callers_stack: []
        )

        callee_class = double(
          'ClassUse',
          method: 'call',
          callers_stack: [caller_class]
        )

        classes_uses = [caller_class, callee_class]
        query = QueryUse.allow(classes_uses)

        hash = { caller_class: { method: ['it'] } }
        query.where(hash)

        expect(query.classes_uses).to eq [callee_class]
      end

      it 'queries an indirect caller using the where format' do
        caller_class = double(
          'ClassUse', method: 'it', callers_stack: []
        )
        callee_class = double(
          'ClassUse', method: 'call', callers_stack: [caller_class]
        )
        indirect_callee_class = double(
          'ClassUse',
          method: 'super_call',
          callers_stack: [callee_class, caller_class]
        )

        classes_uses = [caller_class, callee_class, indirect_callee_class]
        query = QueryUse.allow(classes_uses)

        hash = { caller_class: { method: ['it'] } }
        query.where(hash)

        expect(query.classes_uses).to eq [callee_class, indirect_callee_class]
      end
    end
  end
end
