require "vault/rails"

Vault::Rails.configure do |vault|
  vault.enabled     = true
  vault.application = "demo"
  vault.address     = "http://127.0.0.1:8200"
  vault.token       = File.read("#{ENV["HOME"]}/.vault-token")
end
