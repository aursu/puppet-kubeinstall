require 'English'

Facter.add(:kernelentries) do
  setcode do
    grubby_list = `/usr/sbin/grubby --info=ALL` if File.executable?('/usr/sbin/grubby')

    entries = []
    if grubby_list && $CHILD_STATUS.success?
      token_list = grubby_list.split("\n")
                              .map    { |g| g.split('=', 2) }
                              .reject { |p| p.size < 2 }

      entry = {}
      token_list.each do |token|
        k, v = token
        if k == 'index'
          entries += [entry] if entry['kernel']

          entry = { 'index' => v.to_i }
        else
          entry[k] = if v[0] == %(") && v[-1] == %(")
                       v[1...-1]
                     else
                       v
                     end
        end
      end
      entries
    else
      []
    end
  end
end
