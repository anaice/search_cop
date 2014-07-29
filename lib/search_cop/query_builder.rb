
module SearchCop
  class QueryBuilder
    attr_accessor :query_info, :scope, :sql

    def initialize(model, query, scope)
      self.scope = scope
      self.query_info = QueryInfo.new(model, scope)

      arel = SearchCop::Parser.parse(query, query_info).optimize!

      self.sql = model.connection.visitor.accept(arel)
    end

    def associations
      all_associations - [query_info.model.name.tableize.to_sym]
    end

    private

    def all_associations
      scope.reflection.attributes.values.flatten.uniq.collect { |column| column.split(".").first }.collect { |column| scope.reflection.aliases[column] || column.to_sym }
    end
  end
end
