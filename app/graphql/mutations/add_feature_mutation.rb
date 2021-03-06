Mutations::AddFeatureMutation = GraphQL::Relay::Mutation.define do
  # Used to name derived types, eg `"AddFeatureInput"`:
  name  'AddFeature'

  # Accessible from `inputs` in the resolve function:
  input_field :name, !types.String
  input_field :description, !types.String
  input_field :url, !types.String

  # The result has access to these fields,
  # resolve must return a hash with these keys.
  # On the client-side this would be configured
  # as RANGE_ADD mutation, so our returned fields
  # must conform to that API.
  return_field :featuresConnection, Types::FeatureType.connection_type
  return_field :featureEdge, Types::FeatureType.edge_type
  return_field :viewer, Types::UserType

  resolve ->(object, inputs, ctx) {
    viewer = Database.get_user(1)
    new_feature = Database.add_feature(inputs[:name], inputs[:description], inputs[:url])

    # Use this helper to create the response that a
    # client-side RANGE_ADD mutation would expect.
    range_add = GraphQL::Relay::RangeAdd.new(
      parent: viewer,
      collection: Database.get_features,
      item: new_feature,
      context: ctx,
    )

    response = {
      viewer: viewer,
      featuresConnection: range_add.connection,
      featureEdge: range_add.edge,
    }
  }
end
