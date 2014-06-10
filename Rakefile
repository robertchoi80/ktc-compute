#!/usr/bin/env rake
require 'rake'
require 'rspec/core/rake_task'
require 'berkshelf/cli'

cfg_dir = File.expand_path File.dirname(__FILE__)
ENV['BERKSHELF_PATH'] = cfg_dir + '/.berkshelf'

task default: 'test:quick'

namespace :test do

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = Dir.glob('test/spec/**/*_spec.rb')
    t.rspec_opts = '--color -f d'
  end

  begin
    require 'kitchen/rake_tasks'
    Kitchen::RakeTasks.new
  rescue LoadError
    puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
  end

  begin
    require 'foodcritic'

    task default: [:foodcritic]
    FoodCritic::Rake::LintTask.new do |t|
      t.options = { fail_tags: %w(correctness services libraries deprecated) }
    end
  rescue LoadError
    warn 'Foodcritic Is missing ZOMG'
  end

  begin
    require 'rubocop/rake_task'
    Rubocop::RakeTask.new do |task|
      task.fail_on_error = true
    end
  rescue LoadError
    warn 'Rubocop gem not installed, now the code will look like crap!'
  end

  desc 'Run all of the quick tests.'
  task :quick do
    Rake::Task['test:rubocop'].invoke
    Rake::Task['test:foodcritic'].invoke
    Rake::Task['test:spec'].invoke
  end

  desc 'Run _all_ the tests. Go get a coffee.'
  task :complete do
    if File.exist?('Berksfile.lock')
      Berkshelf::Cli.start(['update'])
    else
      Berkshelf::Cli.start(['install'])
    end
    Rake::Task['test:quick'].invoke
    Rake::Task['test:kitchen:all'].invoke
  end

  desc 'Run CI tests'
  task :ci do
    Rake::Task['test:complete'].invoke
  end
end

desc 'Ensure skeleton files are up to date'
task :skeleton do
  begin
    require 'git'
    g = Git.open('.')

    remotes = g.remotes.map { |r| r.name }
    rname = 'skeleton'
    unless remotes.include?(rname)
      puts 'Adding skeleton remote to your repository'
      git_uri = 'https://github.com/cloudware-cookbooks/skeleton.git'
      g.add_remote(rname, git_uri)
    end

    # fetch & merge remote
    puts 'fetching latest bones'
    g.remote(rname).fetch
    puts 'merging remote branch'
    sh "git merge -X theirs -m 'skel cookbook sync' --squash #{rname}/master"

    # fixup Berkshelf file
    b = File.open('Berksfile', 'r').read.split("\n")
    i = b.index('metadata')
    if i
      h = ['#']
      h << '# vim: set ft=ruby:'
      h << '#'
      h << ''
      h << 'source \'http://cookbooks.mkd2.ktc:26200\''
      h << ''
      b[0, i] = h
      File.open('Berksfile', 'w') { |f| f.write(b.join("\n")) }
    end

    if Dir.exist?('.skel')
      puts 'executing .skel scripts'
      Dir.glob('.skel/*.rb').each { |z| load z }
    end

  rescue => e
    warn 'The skeletons in your closet are unhappy'
    puts e.message
  end
end
