# frozen_string_literal: true

require 'spec_helper'

describe FilterUse do
  describe '.reject' do
    it 'returns FilterUse with classes_uses' do
      classes_uses = [double('ClassUse')]

      filter = FilterUse.reject(classes_uses)

      expect(filter.classes_uses).to eq classes_uses
    end
  end

  describe '#reject' do
    it 'changes filter action' do
      classes_uses = [double('ClassUse')]
      filter = FilterUse.new(classes_uses, :select)

      new_filter = filter.reject

      expect(new_filter.instance_variable_get(:@action)).to eq :reject
    end
  end

  describe '.allow' do
    it 'returns FilterUse with classes_uses' do
      classes_uses = [double('ClassUse')]

      filter = FilterUse.allow(classes_uses)

      expect(filter.classes_uses).to eq classes_uses
    end
  end

  describe '#allow' do
    it 'changes filter action' do
      classes_uses = [double('ClassUse')]
      filter = FilterUse.new(classes_uses, :select)

      new_filter = filter.allow

      expect(new_filter.instance_variable_get(:@action)).to eq :select
    end
  end

  describe '#where' do
    it 'calls methods depending on input hash keys' do
      classes_uses = [double('ClassUse')]
      filter = FilterUse.reject(classes_uses)
      hash = { path: 'my_path', class_name: 'my_class' }

      expect(filter).to receive(:path).with('my_path')
      expect(filter).to receive(:class_name).with('my_class')
      filter.where(hash)
    end

    it 'ignores queries with methods that were not implemented' do
      classes_uses = [double('ClassUse')]
      filter = FilterUse.reject(classes_uses)
      hash = { not_implemented: 'not_implemented' }

      expect { filter.where(hash) }.not_to raise_error
    end

    it 'returns the filter as result' do
      classes_uses = [double('ClassUse', path: 'my_path')]
      filter = FilterUse.allow(classes_uses)
      hash = { path: ['my_path'] }

      filter_output = filter.where(hash)

      expect(filter_output).to eq filter
    end

    context 'filter by path' do
      it 'for a single path' do
        gem_class = double('ClassUse', path: 'gem/my/gem')
        not_gem_class = double('ClassUse', path: 'not/a/gem')

        classes_uses = [gem_class, not_gem_class]
        filter = FilterUse.reject(classes_uses)

        hash = { path: ['gem/'] }
        filter.where(hash)

        expect(filter.classes_uses).to eq [not_gem_class]
      end

      it 'for multiple paths' do
        gem_class = double('ClassUse', path: 'gem/my/gem')
        not_gem_class = double('ClassUse', path: 'not/a/gem')
        controller_class = double('ClassUse', path: 'app/controllers')
        lib_class = double('ClassUse', path: 'lib/my/class')

        classes_uses = [
          gem_class, not_gem_class, controller_class, lib_class
        ]
        filter = FilterUse.allow(classes_uses)

        hash = { path: ['gem/', 'app/'] }
        filter.where(hash)

        expect(filter.classes_uses).to eq [gem_class, controller_class]
      end
    end

    context 'filter by class name' do
      it 'for a single class name' do
        rspec_class = double('ClassUse', name: 'RSpec')
        project_class = double('ClassUse', name: 'Project')

        classes_uses = [rspec_class, project_class]
        filter = FilterUse.allow(classes_uses)

        hash = { class_name: ['Project'] }
        filter.where(hash)

        expect(filter.classes_uses).to eq [project_class]
      end

      it 'for multiple classes names' do
        rspec_class = double('ClassUse', name: 'RSpec')
        kaminari_class = double('ClassUse', name: 'Kaminari')
        module_class = double('ClassUse', name: 'My::Project')
        project_class = double('ClassUse', name: 'Project')

        classes_uses = [
          rspec_class, project_class, module_class, kaminari_class
        ]
        filter = FilterUse.allow(classes_uses)

        hash = { class_name: %w[Project RSpec] }
        filter.where(hash)

        expect(filter.classes_uses).to eq [
          rspec_class, project_class, module_class
        ]
      end
    end

    context 'filter by method name' do
      it 'for a one method' do
        it_method = double('ClassUse', method: 'it')
        describe_method = double('ClassUse', method: 'describe')

        classes_uses = [it_method, describe_method]
        filter = FilterUse.allow(classes_uses)

        hash = { method: ['it'] }
        filter.where(hash)

        expect(filter.classes_uses).to eq [it_method]
      end

      it 'for multiple classes names' do
        it_method = double('ClassUse', method: 'it')
        describe_method = double('ClassUse', method: 'describe')
        run_method = double('ClassUse', method: 'run')

        classes_uses = [
          it_method, describe_method, run_method
        ]
        filter = FilterUse.allow(classes_uses)

        hash = { method: %w[it run] }
        filter.where(hash)

        expect(filter.classes_uses).to eq [
          it_method, run_method
        ]
      end
    end
    context 'filter by caller' do
      it 'filters a direct caller using the where format' do
        caller_class = double(
          'ClassUse', method: 'it', caller_class: nil
        )
        callee_class = double(
          'ClassUse', method: 'call', caller_class: caller_class
        )

        classes_uses = [caller_class, callee_class]
        filter = FilterUse.allow(classes_uses)

        hash = { caller_class: { method: ['it'] } }
        filter.where(hash)

        expect(filter.classes_uses).to eq [callee_class]
      end

      it 'filters an indirect caller using the where format' do
        caller_class = double(
          'ClassUse', method: 'it', caller_class: nil
        )
        callee_class = double(
          'ClassUse', method: 'call', caller_class: caller_class
        )
        indirect_callee_class = double(
          'ClassUse', method: 'super_call', caller_class: callee_class
        )

        classes_uses = [caller_class, callee_class, indirect_callee_class]
        filter = FilterUse.allow(classes_uses)

        hash = { caller_class: { method: ['it'] } }
        filter.where(hash)

        expect(filter.classes_uses).to eq [callee_class, indirect_callee_class]
      end
    end
  end
end
