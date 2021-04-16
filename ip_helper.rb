# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class IPHelper

  def initialize(bits = nil)
    raw_json = Net::HTTP.get URI('https://ip-ranges.amazonaws.com/ip-ranges.json')
    json = JSON[raw_json]
    @ipv4 = json['prefixes']
    @ipv6 = json['ipv6_prefixes']
    @bits = bits
  end

  def ipv6_range
    range_array = []
    prev_value = 0
    ipv6.each do |ip|
      split_ipv6 = ip.split(':')
      range_array << ip if (split_ipv6[0] != prev_value[0] || split_ipv6[1] != prev_value[1])
      prev_value = split_ipv6
    end
    range_array
  end

  def ipv4_range
    range_array = []
    prev_weight = 0
    ipv4.each do |ip|
      weighted = ipv4_split(ip)
      if @bits == 24
        range_array << ip if weighted[0] - prev_weight[0] != 0
      elsif @bits == 16
        if weighted[0] - prev_weight[0] != 0 || weighted[1] - prev_weight[1] != 0
          range_array << ip
        end
      end
      prev_weight = weighted
    end
    range_array
  end

  private

  def ipv4_split(ip)
    return if ip.nil?

    one, two, three, four = ip.split('/')[0].split('.')
    [(one.to_i * 256**4), (two.to_i * 256**3), (three.to_i * 256**2), (four.to_i * 256)]
  end

  def ip_weighting((one, two, three, four))
    weighted = one + two + three + four
    weighted
  end

  def ipv4
    plucked_ipv4 = @ipv4.map { |ip| ip['ip_prefix'] }
    sorted = plucked_ipv4.sort_by { |a| ip_weighting(ipv4_split(a)) }
    sorted
  end

  def ipv6
    plucked_ipv6 = @ipv6.map { |ip| ip['ipv6_prefix'] }
    plucked_ipv6.sort
  end
end
