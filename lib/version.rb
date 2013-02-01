module Kearny
  class << self
    def version
      git_tag = `git describe --always 2>&1`
      $?.success? ? git_tag.chomp : 'unknown'
    end
  end
end
