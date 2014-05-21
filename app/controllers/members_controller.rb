class MembersController < ApplicationController
	require 'rubygems'
	require 'net/ldap'
	
	def new
		@member = Member.new
	end

	def create
		params.require(:member).permit!
		member = Member.new( params[:member] )
		if (from_42_Ldap(member))
			flash[:notice] = 'Member created'
			member.save!
		else
			flash[:notice] = "You're not in 42."
		end
		redirect_to :root
	end

	def index
		@members = Member.all
	end

	def show
		@member = Member.find_by_id( params[:id] )
	end

	private
	def from_42_Ldap(member)

		ldap = Net::LDAP.new(
			:host => "ldap.42.fr",
			:port => 636,
			:base => "ou=2013,ou=people,dc=42,dc=fr",
			:encryption => {:method => :simple_tls},
			:username => member.login,
			:password => member.password)
		if (ldap.bind_as(:base => "ou=2013,ou=people,dc=42,dc=fr", :filter => "(uid=#{member.login})", :password => member.password))
			return true
		else
			return false
		end
	end
end
