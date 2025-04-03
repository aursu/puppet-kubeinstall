# /etc/puppetlabs/facter/facts.d/kubeadm_discovery_certificate_key.rb
require 'facter'
require 'json'
require 'securerandom'
require 'time'
require 'fileutils'

def create_certificate_key
  certificate_key_size = 32
  begin
    rand_bytes = SecureRandom.random_bytes(certificate_key_size)
    return rand_bytes.unpack1('H*')  # Converts bytes to a hex string
  rescue => e
    return nil, e
  end
end

Facter.add(:kubeadm_discovery_certificate_key) do
  confine { File.exist?('/etc/kubernetes/admin.conf') && File.executable?('/usr/bin/kubeadm') }

  setcode do
    json_file = '/etc/puppetlabs/facter/facts.d/kubeadm_certificate_key.json'
    ttl_hours = 2
    current_key = nil

    # Try to read current key and TTL
    if File.exist?(json_file)
      begin
        data = JSON.parse(File.read(json_file))
        key = data['key']
        ttl = Time.parse(data['ttl']) rescue nil

        if key && ttl && Time.now < ttl
          current_key = key
        end
      rescue => e
        Facter.debug("Could not parse #{json_file}: #{e}")
      end
    end

    # If key missing or expired, generate new one and upload certs
    if current_key.nil?
      new_key, err = create_certificate_key

      if new_key.nil?
        Facter.warning("Failed to generate certificate key: #{err}")
        next nil
      end

      ttl_time = (Time.now + ttl_hours * 3600).utc.iso8601
      cmd = "/usr/bin/kubeadm init phase upload-certs --upload-certs --certificate-key #{new_key}"
      output = `#{cmd}`

      if $CHILD_STATUS.success?
        current_key = new_key
        FileUtils.mkdir_p(File.dirname(json_file))
        File.write(json_file, JSON.pretty_generate({ "key" => current_key, "ttl" => ttl_time }))
      else
        Facter.warning("Failed to upload certs: #{output}")
        current_key = nil
      end
    end

    current_key
  end
end
