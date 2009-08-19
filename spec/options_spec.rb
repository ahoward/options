require File.dirname(__FILE__) + "/spec_helper"
require 'options'

describe Options do 
  describe "validation" do 
    it "should be able to detect extraneous options" do 
      lambda{
        Options.parse({:this => 'test'}).validate([:foo, :bar])
      }.should raise_error(ArgumentError, "Unrecognized options: this")
    end

    it "should be able to detect extraneous options from required and options form" do 
      lambda{
        Options.parse({:foo => 'this', :this => 'test'}).validate(:required => [:foo], :optional => [:bar])
      }.should raise_error(ArgumentError, "Unrecognized options: this")
    end

    it "should accept required and optional options" do 
      lambda{
        Options.parse({:foo => 'this', :bar=> 'test'}).validate(:required => [:foo], :optional => [:bar])
      }.should_not raise_error
    end

    it "should accept options from simple list" do 
      lambda{
        Options.parse({:foo => 'this', :bar => 'that'}).validate([:foo, :bar])
      }.should_not raise_error
    end

    it "should be able to detect missing required options" do 
      lambda{
        Options.parse({:this => 'test'}).validate(:required => [:foo, :bar], :optional => [:this])
      }.should raise_error(ArgumentError, "Required options are missing: foo, bar")
    end
  end
end
