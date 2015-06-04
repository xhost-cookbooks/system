# More info at https://github.com/guard/guard#readme

# waiting for guard-foodcritic updates
# https://github.com/cgriego/guard-foodcritic/issues/7
group :style do
  guard 'foodcritic', cookbook_paths: '.', all_on_start: false do
    watch(%r{attributes\/.+\.rb$})
    watch(%r{providers\/.+\.rb$})
    watch(%r{recipes\/.+\.rb$})
    watch(%r{resources\/.+\.rb$})
    watch('metadata.rb')
  end
end

group :lint do
  guard 'rubocop' do
    watch(%r{attributes\/.+\.rb$})
    watch(%r{providers\/.+\.rb$})
    watch(%r{recipes\/.+\.rb$})
    watch(%r{resources\/.+\.rb$})
    watch(%r{test\/.+\.rb$})
    watch('metadata.rb')
    watch('Rakefile')
  end
end

scope groups: [:lint, :style]
