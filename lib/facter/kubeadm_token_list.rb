require 'yaml'
require 'openssl'
require 'date'
require 'English'

Facter.add(:kubeadm_token_list) do
  setcode do
    token_list_yaml = `/usr/bin/kubeadm token list -o yaml` if File.executable?('/usr/bin/kubeadm')

    if token_list_yaml && $CHILD_STATUS.success?
      token_list = token_list_yaml.split('---').map do |t|
        begin
          YAML.safe_load(t)
        rescue Psych::SyntaxError
          false
        end
      end
      token_list.select { |t| t.is_a?(Hash) && t.any? }
                .sort_by { |e| (e['expires']) ? DateTime.parse(e['expires']) : DateTime.new(0) }
                .reverse
    else
      []
    end
  end
end

Facter.add(:kubeadm_discovery_token_ca_cert_hash) do
  setcode do
    begin
      c = File.read('/etc/kubernetes/pki/ca.crt')
      p = OpenSSL::X509::Certificate.new(c).public_key.to_der
      h = OpenSSL::Digest::SHA256.new.hexdigest(p)
      "sha256:#{h}"
    rescue OpenSSL::X509::CertificateError => e
      Puppet.warning(_('Failed to read X.509 Certificate data (%{message})') % { message: e.message })
      nil
    rescue SystemCallError # Errno::ENOENT
      nil
    end
  end
end
