class Member < ActiveRecord::Base
	validates_uniqueness_of :login
#	before_save :encrypt_password
end
