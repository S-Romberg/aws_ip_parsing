# frozen_string_literal: true

require './ip_helper.rb'

helper = IPHelper.new(24)
range = helper.ipv4_range
puts range
