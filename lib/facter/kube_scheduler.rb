Facter.add(:kube_scheduler) do
  confine { File.exist? '/etc/kubernetes/manifests/kube-scheduler.yaml' }
  config = {}
  setcode do
    begin
      data = File.read('/etc/kubernetes/manifests/kube-scheduler.yaml')
      config = YAML.safe_load(data)
    rescue SystemCallError => e # Errno::ENOENT
      Facter.warn("Failed to handle file: #{e.class}: #{e}")
    rescue Psych::SyntaxError => e
      Facter.warn("Failed to interpret file as YAML: #{e.class}: #{e}")
    end
    config
  end
end
