# frozen_string_literal: true

require 'openssl'
require 'vault'
require 'base64'

module Api
  module V1
    class EncryptionController < ApplicationController
      skip_before_action :authenticate_request!

      # Method to generate Diffie-Hellman keys
      def generate_keys
        dh1 = OpenSSL::PKey::DH.new(512)
        der = dh1.private_to_der
        request_id = SecureRandom.uuid
        vault_path = "secret/data/#{request_id}"
        data_to_store = { der: Base64.strict_encode64(der) }
        Vault.logical.write(vault_path, data: data_to_store)
        render json: {
          p: dh1.p.to_s,
          g: dh1.g.to_s,
          pub_key: dh1.pub_key.to_s,
          request_id: request_id
        }
      end

      # Method to perform key exchange and compute symmetric keys
      def compute_shared_secret
        begin
          vault_path = "secret/data/#{params[:request_id]}"
          key_path = Vault.logical.read(vault_path)
          der = key_path&.data&.dig(:data, :der)
          dh = OpenSSL::PKey::DH.new(Base64.strict_decode64(der))
          shared_key = dh.compute_key(OpenSSL::BN.new(params[:pub_key])).unpack1('H*')
          request_id = SecureRandom.uuid
          Vault.logical.write("secret/data/#{request_id}", data: { shared_key: Base64.strict_encode64(shared_key) })
          Vault.logical.delete("secret/data/#{params[:request_id]}")
          render json: { success: true, message: 'Encryption handshake successful', request_id: request_id }
        rescue StandardError => e
          render json: { success: false, message: e.message }, status: :internal_server_error
        end
      end
      # Perform symmetric encryption using shared key
      def encrypt(object, path)
        unless object[:data].nil?
          vault_path = "secret/data/#{path}"
          key_path = Vault.logical.read(vault_path)
          shared_key = key_path&.data&.dig(:data, :shared_key)
          key = Base64.strict_decode64(shared_key)
          cipher = OpenSSL::Cipher.new('AES-256-CBC')
          cipher.encrypt
          iv = cipher.random_iv
          cipher.iv = iv
          cipher.key = key[0, 32].ljust(32, '0')
          object[:data] = (cipher.update(object[:data].to_json.to_s) + cipher.final).unpack('H*').first
          object[:iv] = iv.unpack('H*').first
          object
        end
      end

      # Perform symmetric decryption using shared key
      def decrypt(data, path, iv)
        begin
          vault_path = "secret/data/#{path}"
          key_path = Vault.logical.read(vault_path)
          shared_key = key_path&.data&.dig(:data, :shared_key)
          key = Base64.strict_decode64(shared_key)
          decipher = OpenSSL::Cipher.new('AES-256-CBC')
          decipher.decrypt
          decipher.key = key[0, 32].ljust(32, '0')
          decipher.iv = [iv].pack('H*')

         decipher.update([data].pack('H*')) + decipher.final
          # Update the internal environment hash of the ActionDispatch::Request
          # rack_request = Rack::Request.new(request.env.merge({ 'rack.input' => StringIO.new(data) }))
          # request.instance_variable_set(:@env, rack_request.env)


        rescue OpenSSL::Cipher::CipherError => e
          # Log decryption error
          puts "Decryption error: #{e.message}"
          nil
        rescue StandardError => e
          # Catch any other unexpected errors
          puts "Unexpected error during decryption: #{e.message}"
          nil
        end
      end
    end
  end
end