# frozen_string_literal: true

require './ip_helper.rb'

helper = IPHelper.new
range = helper.ipv6_range
puts range
