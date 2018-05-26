require 'spec_helper'

describe file('/etc/apt/sources.list.d/treasure-data.list') do
  it { should exist }
  it { should be_file }
  code_name = property['ansible_distribution_release']
  it { should contain "deb http://packages.treasuredata.com/3/debian/#{code_name}/ #{code_name} contrib" }
end

describe package('td-agent') do
  it { should be_installed }
end

describe file('/etc/td-agent/td-agent.conf') do
  it { should exist }
  it { should be_file }
  property['fluentd_filter_cfg'].each do |filter|
    it { should contain "<filter #{e(filter['pattern'])}>" }
  end
  property['fluentd_match_cfg'].each do |match|
    it { should contain "<match #{e(match['pattern'])}>" }
  end
end

property['fluentd_plugins'].each do |plugin|
  describe command('/usr/sbin/td-agent-gem list --local') do
    its(:stdout) { should contain plugin }
  end
end

describe service('td-agent') do
  it { should be_enabled }
  it { should be_running }
end
