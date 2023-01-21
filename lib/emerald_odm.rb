require 'emerald_odm/version'
require 'mongo'

module EmeraldODM

  def self.databases_settings
    @databases_settings ||= {}
  end

  module Connector

    # @return [Mongo::Client] The database client
    def self.database(db_name)
      if databases_instances[db_name].nil?
        db_settings = EmeraldODM.databases_settings[db_name]
        raise Exceptions::MissingDatabaseSettings.new("Database settings not found for #{db_name}") if db_settings.nil? || db_settings.empty?
        self.databases_instances[db_name] = Mongo::Client.new(*db_settings)
      end
      databases_instances[db_name]
    end

    def self.databases_instances
      @databases_instances ||= {}
    end
  end

  class AttrInitializer
    attr_reader :document

    def initialize(document)
      self.class.fields.each do |field|
        document_value = document[field]
        send("#{field}=", document_value) unless document_value.nil?
      end
      instance_variable_set('@document', document)
    end

    # @return [Array]
    def self.fields
      public_instance_methods = self.public_instance_methods(false).grep(/=$/)
      rejected_attr_names = %w[document]
      fields = []
      public_instance_methods.each do |attr|
        attr_name = attr.to_s.gsub('=', '')
        next if rejected_attr_names.include?(attr_name)
        fields << attr_name
      end
      fields
    end

    def nil?
      document.nil? || document.empty?
    end
  end

  class Collection < AttrInitializer

    # @return [Symbol, nil]
    def self.db_name
      nil
    end

    # @return [Symbol, nil]
    def self.collection_name
      nil
    end

    # @return [Mongo::Collection] The collection
    def self.collection
      Connector.database(db_name&.to_sym)[collection_name&.to_sym]
    end

    def self.is_valid_fields?(query_fields)
      (query_fields - fields).count == 0
    end

    # @param [Hash] filter The filter
    # @param [Hash] projection The projection
    # @param [Hash] sort The sort
    # @param [Integer] limit The limit
    # @return [Array<self>] The documents
    def find(filter: {}, projection: {}, sort: {}, limit: 0)
      self.class.validate_fields_from_stages(filter, projection, sort)

      if projection.empty?
        projection = self.class.fields.map { |field| [field, 1] }.to_h
      end

      query = self.class.collection.find(filter).projection(projection).sort(sort)
      if limit > 0
        query = query.limit(limit)
      end
      query.to_a.map { |document| self.class.new(document) }
    end

    def self.find(filter: {}, projection: {}, sort: {}, limit: 0)
      new({}).find(filter: filter, projection: projection, sort: sort, limit: limit)
    end

    def self.update(type, filter, set: {}, unset: {})
      validate_fields_from_stages(filter, set, unset)
      update = {}
      update[:'$set'] = set unless set.empty?
      update[:'$unset'] = unset unless unset.empty?

      if update.empty?
        raise 'Update without set or unset'
      elsif filter.empty?
        raise 'Update without filter'
      end

      if type == :one
        update_response = collection.update_one(filter, update).to_a
      elsif type == :many
        update_response = collection.update_many(filter, update).to_a
      else
        raise 'Invalid type'
      end

      update_response.first
    end

    def self.update_one(filter, set: {}, unset: {})
      update(:one, filter, set: set, unset: unset)
    end

    def self.update_many(filter, set: {}, unset: {})
      update(:many, filter, set: set, unset: unset)
    end

    def self.validate_fields_from_stages(*stages)
      validate_dollar_stages(*stages)
      validate_common_stages(*stages)
    end

    def self.validate_dollar_stages(*stages)
      known_dollar_stages = %w[$and $or $in]
      formatted_stages = stages.map { |stage| stage.keys }.flatten.uniq.map{|k| k.to_s}.select{|k| k.start_with?('$')}
      unless (formatted_stages - known_dollar_stages).empty?
        raise "Invalid dollar stages: #{(formatted_stages - known_dollar_stages)}"
      end
    end

    def self.validate_common_stages(*stages)
      formatted_stages = stages.map { |stage| stage.keys }.flatten.uniq.map{|k| k.to_s}.reject{|k| k.start_with?('$')}
      formatted_stages = formatted_stages.map{|f| f.to_s.split('.').first}.uniq
      unless is_valid_fields?(formatted_stages)
        raise "Invalid fields: #{(formatted_stages - self.fields)}"
      end
    end

  end

  module Exceptions
    class InvalidFields < StandardError; end
    class InvalidUpdateType < StandardError; end
    class EmptyFilter < StandardError; end
    class EmptyUpdate < StandardError; end
    class MissingDatabaseSettings < StandardError; end
  end
end

