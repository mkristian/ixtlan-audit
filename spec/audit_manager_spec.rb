require 'dm-core'
require 'dm-migrations'
require 'slf4r/ruby_logger'
require 'ixtlan/audit/manager'
require 'ixtlan/audit/resource'

Audit = Ixtlan::Audit::Audit

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.finalize
DataMapper.repository.auto_migrate!

describe Ixtlan::Audit::Manager do

  before { subject.model = Audit }

  it 'should collect log events and the save them all in one go' do
    size = Audit.all.size
    subject.push( "login1", "POST", "path1", "msg1" )
    subject.push( "login2", "DELETE", "path2", "msg2" )
    subject.push( "login3", "GET", "path3", "msg3" )
    subject.save_all

    Audit.all.size.should == size + 3
  end

  it "should clean up audit logs" do
    Audit.create(:message => "msg", :login => "login")
    Audit.all.size.should > 0
    subject.keep_logs = 0
    Audit.all.size.should == 0
    subject.push( "login1", "PUT", "path1", "msg1" )
    subject.push( "login2", "OPTION", "path2", "msg2" )
    subject.save_all
    Audit.all.size.should == 2
  end
end
