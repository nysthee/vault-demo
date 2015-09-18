class Person < ActiveRecord::Base
  include Vault::EncryptedModel
  vault_attribute :credit_card
end
