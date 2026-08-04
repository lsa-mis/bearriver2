# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Solid Queue / Cache / Cable', type: :model do
  describe 'schema' do
    it 'creates Solid Cache, Cable, and Queue tables in the primary database' do
      expect(SolidCache::Entry.table_exists?).to be(true)
      expect(SolidCable::Message.table_exists?).to be(true)
      expect(SolidQueue::Job.table_exists?).to be(true)
      expect(ActiveRecord::Base.connection.data_source_exists?('solid_queue_ready_executions')).to be(true)
    end
  end

  describe 'Solid Cache' do
    it 'reads and writes through solid_cache_store on the primary DB' do
      store = ActiveSupport::Cache.lookup_store(:solid_cache_store)
      key = "solid-cache-spec-#{SecureRandom.hex(4)}"

      expect(store.write(key, { ok: true })).to be_truthy
      expect(store.read(key)).to eq(ok: true)
      expect(SolidCache::Entry.count).to be >= 1
    ensure
      store&.delete(key)
    end
  end

  describe 'Solid Queue' do
    it 'enqueues Active Job records into solid_queue_jobs on the primary DB' do
      previous = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :solid_queue

      expect {
        ApplicationJob.perform_later
      }.to change(SolidQueue::Job, :count).by(1)

      job = SolidQueue::Job.order(:id).last
      expect(job.class_name).to eq('ApplicationJob')
      expect(job.queue_name).to be_present
    ensure
      ActiveJob::Base.queue_adapter = previous
    end
  end

  describe 'Solid Cable' do
    it 'persists Action Cable messages in solid_cable_messages' do
      expect {
        SolidCable::Message.broadcast('test-channel', 'hello-solid-cable')
      }.to change(SolidCable::Message, :count).by(1)

      message = SolidCable::Message.order(:id).last
      expect(message.channel).to eq('test-channel')
      expect(message.payload).to eq('hello-solid-cable')
      expect(message.channel_hash).to eq(SolidCable::Message.channel_hash_for('test-channel'))
    end
  end

  describe 'single-database configuration' do
    it 'does not configure separate queue/cache/cable databases' do
      database_yml = Rails.root.join('config/database.yml').read
      expect(database_yml).not_to match(/^\s*queue:/)
      expect(database_yml).not_to match(/^\s*cache:/)
      expect(database_yml).not_to match(/^\s*cable:/)

      cache_yml = Rails.root.join('config/cache.yml').read
      expect(cache_yml).to include("staging:\n  <<: *default")
      expect(cache_yml).to include("production:\n  <<: *default")
      expect(cache_yml).not_to match(/^\s*database:\s*cache/)

      cable_yml = Rails.root.join('config/cable.yml').read
      expect(cable_yml).to include("staging:\n  adapter: solid_cable")
      expect(cable_yml).to include("production:\n  adapter: solid_cable")
      expect(cable_yml).not_to match(/^\s*connects_to:/)

      production_rb = Rails.root.join('config/environments/production.rb').read
      staging_rb = Rails.root.join('config/environments/staging.rb').read
      [production_rb, staging_rb].each do |source|
        expect(source).to include('solid_cache_store')
        expect(source).to include(':solid_queue')
        expect(source).not_to include('solid_queue.connects_to')
      end
    end
  end
end
