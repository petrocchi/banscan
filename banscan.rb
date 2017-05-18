#!/usr/bin/ruby

=begin

banport - Easy and fast port scanner for penetration test

THIS TOOL IS FOR LEGAL PURPOSES ONLY!


Copyright (C) 2017 Luca Petrocchi <petrocchi@myoffset.me>

DATE:		18/05/2017
AUTHOR:		Luca Petrocchi
EMAIL:		petrocchi@myoffset.me
WEBSITE:	https://myoffset.me/
URL:		https://github.com/petrocchi


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

banport <host> [OPTION]
banport - Easy port scanner for penetration test

  <host>		Host or IP target

[OPTION]
  empty			Default range ports (1 to 1024)
  port			Singole port
  port,port		Many ports (21,22,23,25,80,139,443,445)
  port-port		Range of ports (21-445)

END

def try(host, port)
	thread = []

	thread << Thread.new do
		begin
			begin
				Timeout::timeout(30) {
					TCPSocket.open(host, port)
					puts "#{port}/tcp\topen\n"
				}
			rescue Timeout::Error
			end
		rescue Errno::ECONNREFUSED
		end
	end

	thread.each { |th| th.join }
end

def scan_d(host)
	for i in (1..1024)
		try(host, i)
	end
end

def scan_0(host, ports)
	until ports[0] == (ports[1]+1)
		try(host, ports[0])
		ports[0] += 1
	end
end

def scan_1(host, ports)
	ports.each { |port| try(host, port) }
end

begin
	if ARGV.length != 1 && ARGV.length != 2
		STDERR.puts "#{TXT_USAGE}"
		exit 0
	end

	if ARGV.length == 1
		scan_d(ARGV[0])
	else
		ports = []

		case ARGV[1].strip
			when /(^\d+)(\-{1})(\d+$)/
				ARGV[1].split("-").map{ |port| ports.push port.to_i }
				scan_0(ARGV[0], ports)
			when  /(^\d+\,\d+)/
				ARGV[1].split(",").map{ |port| ports.push port.to_i }
				scan_1(ARGV[0], ports)
			when /\d+/
				try(ARGV[0], ARGV[1].to_i)
			else
				STDERR.puts "#{TXT_USAGE}"
				exit 1
		end
	end
end

