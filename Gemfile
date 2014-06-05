source 'https://rubygems.org'

# get this from git for the chefignore issues
gem 'berkshelf'

group 'develop' do
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'kitchen-openstack'
  gem 'rake'
  # 3.0.3 is ancient.  git until there's another release
  gem 'foodcritic',
      git: 'https://github.com/acrmp/foodcritic.git'
  gem 'rubocop'
  gem 'knife-cookbook-doc'
  gem 'chefspec', '>= 3.2.0'
  gem 'git'
end
