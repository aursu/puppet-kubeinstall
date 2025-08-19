# /etc/puppetlabs/facter/facts.d/kubeadm_discovery_certificate_key.rb
require 'facter'
require 'json'
require 'securerandom'
require 'time'
require 'fileutils'
require 'open3'

def create_certificate_key
  SecureRandom.random_bytes(32).unpack1('H*')
rescue => e
  Facter.warning("Certificate key generation error: #{e.message}")
  nil
end

Facter.add(:kubeadm_discovery_certificate_key) do
  confine do
    kubeadm = Facter::Core::Execution.which('kubeadm') || '/usr/bin/kubeadm'
    File.exist?('/etc/kubernetes/admin.conf') && File.executable?(kubeadm)
  end

  setcode do
    json_file = '/etc/puppetlabs/facter/facts.d/kubeadm_certificate_key.json'
    ttl_hours = 2
    kubeadm = Facter::Core::Execution.which('kubeadm') || '/usr/bin/kubeadm'

    current_key = nil
    now = Time.now.utc

    if File.exist?(json_file)
      begin
        data = JSON.parse(File.read(json_file))
        key = data['key']
        ttl = begin
                Time.parse(data['ttl']).utc
              rescue
                nil
              end
        if key && ttl && now < ttl
          current_key = key
          Facter.debug("Existing certificate key valid until #{ttl}")
        end
      rescue JSON::ParserError => e
        Facter.debug("JSON parsing error in #{json_file}: #{e.message}")
      rescue => e
        Facter.debug("Unknown error while reading #{json_file}: #{e.message}")
      end
    end

    if current_key.nil?
      new_key = create_certificate_key
      if new_key.nil?
        Facter.warning('Certificate key could not be generated')
        next nil
      end

      ttl_time = (now + ttl_hours * 3600).iso8601
      cmd = "#{kubeadm} init phase upload-certs --upload-certs --certificate-key #{new_key}"

      _, stderr, status = Open3.capture3(cmd)
      if status.success?
        current_key = new_key
        begin
          FileUtils.mkdir_p(File.dirname(json_file))
          File.write(json_file, JSON.pretty_generate({ 'key' => current_key, 'ttl' => ttl_time }))
          File.chown(0, 0, json_file)
          File.chmod(0o600, json_file)
          Facter.debug("Generated new certificate key, valid until #{ttl_time}")
        rescue => e
          Facter.warning("Failed to write JSON file #{json_file}: #{e.message}")
          current_key = nil
        end
      else
        Facter.warning("Failed to upload certs: #{stderr.strip}")
        current_key = nil
      end
    end

    current_key
  end
end
