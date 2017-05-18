#!/usr/bin/ruby

=begin

banport - Easy and fast TCP/UDP port scanner for penetration test

THIS TOOL IS FOR LEGAL PURPOSES ONLY!


Copyright (C) 2017 Luca Petrocchi <petrocchi@myoffset.me>

DATE:		18/05/2017
AUTHOR:		Luca Petrocchi
EMAIL:		petrocchi@myoffset.me
WEBSITE:	https://myoffset.me/
URL:		https://github.com/petrocchi


banport is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

banscan.rb is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.

=end

require 'socket'
require 'timeout'

TXT_USAGE = <<END

banport <t|u> <host> [OPTION]
banport - Easy TCP/UDP port scanner for penetration test

  <t|u>			TCP or UDP scan
  <host>		Host or IP target

[OPTION]
  empty			Default range ports (1 to 1024)
  port			Singole port
  port,port		Many ports (21,22,23,25,80,139,443,445,3389)
  port-port		Range of ports (21-445)

Examples:
  ./banport t localhost
  ./banport t 127.0.0.1 21,25,80,139,443,445,3389
  ./banport u 192.168.1.1 13-1000

END

def goodprint(port, type, state)
	str = port.to_s

	output = String.new
	output << str

	output << "/tcp" if type == 't'
	output << "/udp" if type == 'u'
	
	(1..(11 - str.length)).each { output << ' ' }

	output << "open\n" if state == 'o'
	output << "filtered|open\n" if state == 'f'

	puts output
end

def try(host, port, protocol)
	if protocol == "t"
		begin
			TCPSocket.new(host, port)
			goodprint(port, 't', 'o')
		rescue
		end
	else
		stream = UDPSocket.new
		stream.connect(host, port)

		(1..5).each do |i|
			begin	
				Timeout::timeout(i*0.5) {
					stream.write("\0")
					stream.recv(10) 
					goodprint(port, 'u', 'o')
				}
			rescue Errno::ECONNREFUSED
				break
			rescue Timeout::Error
				goodprint(port, 'u', 'f') if i == 5
			else
				break
			end
		end
	end
end

def scan_d(host, protocol)
	puts "[+] banscan start to (#{host}) on port from 1 to 1024\n\n"

	for i in (1..1024)
		try(host, i, protocol)
	end
end

def scan_0(host, ports, protocol)
	puts "[+] banscan start to (#{host}) on port from #{ports[0]} to #{ports[1]}\n\n"

	until ports[0] == (ports[1]+1)
		try(host, ports[0], protocol)
		ports[0] += 1
	end
end

def scan_1(host, ports, protocol)
	str = String.new
	ports.each { |port| str << "#{port}," }

	puts "[+] banscan start to (#{host}) on port #{str[0,(str.length-1)]}\n\n"

	ports.each { |port| try(host, port, protocol) }
end

begin
	if ARGV.length != 2 && ARGV.length != 3 || (ARGV[0] != 't' && ARGV[0] != 'u')
		STDERR.puts "#{TXT_USAGE}"
		exit 0
	end

	host = ARGV[1]
	protocol = ARGV[0]

	if ARGV.length == 2
		scan_d(host, protocol)
	else

		ports = []

		case ARGV[2].strip
			when /(^\d+)(\-{1})(\d+$)/
				ARGV[2].split("-").map{ |port| ports.push port.to_i }
				scan_0(host, ports, protocol)
			when  /(^\d+\,\d+)/
				ARGV[2].split(",").map{ |port| ports.push port.to_i }
				scan_1(host, ports, protocol)
			when /\d+/
				port = ARGV[2].to_i
				puts "[+] banscan start to (#{ARGV[1]}) on port #{port}\n\n"
				try(host, port, protocol)
			else
				STDERR.puts "#{TXT_USAGE}"
				exit 1
		end
	end

	puts "\n[+] Finish\n"
end

