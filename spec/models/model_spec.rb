# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Post, type: :model do
  subject { Post.new }

  context 'Generic tests' do
    it 'has STOMP_ATTRIBUTES constant' do
      expect(Post::STOMP_ATTRIBUTES).to be_present
    end

    it 'responds to STOMP_ATTRIBUTES accessors' do
      Post::STOMP_ATTRIBUTES.each do |attr|
        expect(subject).to respond_to(attr)
      end
    end

    it 'responds to class level methods' do
      expect(Post).to respond_to(:define_steps)
      expect(Post).to respond_to(:define_step_validations)
      expect(Post).to respond_to(:stomp!)
    end

    it 'responds to instance level methods' do
      expect(subject).to respond_to(:step!)
      expect(subject).to respond_to(:next_step!)
      expect(subject).to respond_to(:previous_step!)
      expect(subject).to respond_to(:has_previous_step?)
      expect(subject).to respond_to(:has_next_step?)
      expect(subject).to respond_to(:current_step_is?)
      expect(subject).to respond_to(:completed?)
      expect(subject).to respond_to(:create_attempt?)
      expect(subject).to respond_to(:first_step?)
      expect(subject).to respond_to(:last_step?)
      expect(subject).to respond_to(:all_steps_valid?)
    end
  end

  context 'Initialization' do
    let(:serialized_steps_data) { { current_step: :step_one, previous_step: nil }.to_json }

    it 'calls deserialize_and_set_data with serialized_steps_data' do
      expect_any_instance_of(Post).to receive(:deserialize_and_set_data).with(serialized_steps_data)
      Post.new(serialized_steps_data: serialized_steps_data)
    end

    it 'sets the attributes correctly from steps_data' do
      post = Post.new(serialized_steps_data: serialized_steps_data)
      expect(post.current_step).to eq(:step_one)
      expect(post.previous_step).to be_nil
    end

    it 'calls update_attributes_from_step_data' do
      expect_any_instance_of(Post).to receive(:update_attributes_from_step_data)
      Post.new(serialized_steps_data: serialized_steps_data)
    end

    it 'properly initializes without serialized_steps_data' do
      expect { Post.new }.not_to raise_error
    end
  end

  context "when stomp_validation is set to :each_step" do
    before do
      Post.stomp!(validate: :each_step)
    end

    it "initializes with the correct default values" do
      expect(subject.current_step).to eq(:step_1)
      expect(subject.completed_steps).to eq([])
    end
  end

  context "when stomp_validation is set to :once" do
    before do
      Post.stomp!(validate: :once)
    end

    it "initializes with the correct default values" do
      expect(subject.current_step).to eq(:step_1)
      expect(subject.completed_steps).to eq([])
    end
  end
end
