class MembersController < ApplicationController
	require 'rubygems'
	require 'net/ldap'
	
	def new
		@member = Member.new
	end

	def logout
		reset_session
		redirect_to :root
	end

	def create
		params.require(:member).permit!
		if (from_42_Ldap(params[:member]))
			params[:member][:password] =  Digest::SHA2.hexdigest(params[:member][:password])
			member = Member.new( params[:member] )
			flash[:notice] = 'Member created'
			if (!member.save)
				flash[:notice] = 'Already into databse'
			else
				session[:login] = params[:login]
				session[:id] = member.id
			end
		else
			flash[:notice] = "You're not in 42."
		end
		redirect_to :root
	end

	def signin
		if (!(@member = Member.find_by(login: params[:login], password: Digest::SHA2.hexdigest(params[:password]))))
			flash[:notice] = 'Wrong login or password'
		else
			flash[:notice] = 'You\'re logged in'
			session[:login] = params[:login]
			session[:id] = @member.id
		end
		redirect_to :root
	end

	def index
		@members = Member.all
	end

	def show
		@member = Member.find_by_id( params[:id])
	end

	# Return true if member is in 42 Ldap, false otherwise.
	private
	def from_42_Ldap(member)

		ldap = Net::LDAP.new(
			:host => "ldap.42.fr",
			:port => 636,
			:base => "ou=2013,ou=people,dc=42,dc=fr",
			:encryption => {:method => :simple_tls},
			:username => member[:login],
			:password => member[:password])
		if (ldap.bind_as(:base => "ou=2013,ou=people,dc=42,dc=fr", :filter => "(uid=#{member[:login]})", :password => member[:password]))
			return true
		else
			return false
		end
	end
end
