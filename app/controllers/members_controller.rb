class MembersController < ApplicationController
	def new
		@member = Member.new
	end

	def create
		params.require(:member).permit!
		member = Member.new( params[:member] )
		if (member.login != "" && member.password != "")
			flash[:notice] = 'Member created'
			member.save!
		end
		redirect_to :root
	end

	def index
		@members = Member.all
	end

	def show
		@member = Member.find_by_id( params[:id] )
	end
end
