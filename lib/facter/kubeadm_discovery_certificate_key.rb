# /etc/puppetlabs/facter/facts.d/kubeadm_discovery_certificate_key.rb
require 'facter'
require 'json'
require 'securerandom'
require 'time'
require 'fileutils'

JSON_FILE = '/etc/puppetlabs/facter/facts.d/kubeadm_certificate_key.json'
TTL_HOURS = 2

def create_certificate_key
  certificate_key_size = 32
  rand_bytes = SecureRandom.random_bytes(certificate_key_size)
  [rand_bytes.unpack1('H*'), nil]
rescue => e
  [nil, e]
end

Facter.add(:kubeadm_discovery_certificate_key) do
  confine do
    File.exist?('/etc/kubernetes/admin.conf') &&
    File.executable?('/usr/bin/kubeadm')
  end

  setcode do
    current_key = nil

    if File.exist?(JSON_FILE)
      begin
        data = JSON.parse(File.read(JSON_FILE))
        key = data['key']
        ttl = Time.parse(data['ttl']).utc rescue nil
        if key && ttl && Time.now.utc < ttl
          current_key = key
          Facter.debug("Existing certificate key valid until #{ttl}")
        end
      rescue => e
        Facter.debug("Failed to parse #{JSON_FILE}: #{e}")
      end
    end

    if current_key.nil?
      new_key, err = create_certificate_key
      if new_key.nil?
        Facter.warning("Failed to generate certificate key: #{err}")
        next nil
      end

      ttl_time = (Time.now.utc + TTL_HOURS * 3600).iso8601
      cmd = "/usr/bin/kubeadm init phase upload-certs --upload-certs --certificate-key #{new_key}"
      output = `#{cmd}`

      if $CHILD_STATUS.success?
        current_key = new_key
        FileUtils.mkdir_p(File.dirname(JSON_FILE))
        File.write(JSON_FILE, JSON.pretty_generate({ "key" => current_key, "ttl" => ttl_time }))
        File.chmod(0600, JSON_FILE)
        Facter.debug("Generated new certificate key, valid until #{ttl_time}")
      else
        Facter.warning("Failed to upload certs: #{output.strip}")
        current_key = nil
      end
    end

    current_key
  end
end
