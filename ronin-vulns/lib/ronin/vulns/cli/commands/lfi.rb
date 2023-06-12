# frozen_string_literal: true
#
# ronin-vulns - A Ruby library for blind vulnerability testing.
#
# Copyright (c) 2022-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# ronin-vulns is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-vulns is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-vulns.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/vulns/cli/web_vuln_command'
require 'ronin/vulns/lfi'

module Ronin
  module Vulns
    class CLI
      module Commands
        #
        # Scans URL(s) for Local File Inclusion (LFI) vulnerabilities
        #
        # ## Usage
        #
        #     ronin-vulns lfi [options] {URL ... | --input FILE}
        #
        # ## Options
        #
        #         --first                      Only find the first vulnerability for each URL
        #     -A, --all                        Find all vulnerabilities for each URL
        #     -H, --header "Name: value"       Sets an additional header
        #     -C, --cookie COOKIE              Sets the raw Cookie header
        #     -c, --cookie-param NAME=VALUE    Sets an additional cookie param
        #     -R, --referer URL                Sets the Referer header
        #     -F, --form-param NAME=VALUE      Sets an additional form param
        #         --test-query-param NAME      Tests the URL query param name
        #         --test-all-query-params      Test all URL query param names
        #         --test-header-name NAME      Tests the HTTP Header name
        #         --test-cookie-param NAME     Tests the HTTP Cookie name
        #         --test-all-cookie-params     Test all Cookie param names
        #         --test-form-param NAME       Tests the form param name
        #     -i, --input FILE                 Reads URLs from the list file
        #     -O, --os unix|windows            Sets the OS to test for
        #     -D, --depth COUNT                Sets the directory depth to escape up
        #     -B null_byte|double_escape|base64|rot13|zlib,
        #         --filter-bypass              Sets the filter bypass strategy to use
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     [URL ...]                        The URL(s) to scan
        #
        class Lfi < WebVulnCommand

          usage '[options] {URL ... | --input FILE}'

          option :os, short: '-O',
                      value: {
                        type: [:unix, :windows]
                      },
                      desc: 'Sets the OS to test for'

          option :depth, short: '-D',
                         value: {
                           type:  Integer,
                           usage: 'COUNT'
                         },
                         desc: 'Sets the directory depth to escape up'

          option :filter_bypass, short: '-B',
                                 value: {
                                   type: [
                                     :null_byte,
                                     :double_escape,
                                     :base64,
                                     :rot13,
                                     :zlib
                                   ]
                                 },
                                 desc: 'Sets the filter bypass strategy to use'

          description 'Scans URL(s) for Local File Inclusion (LFI) vulnerabilities'

          man_page 'ronin-vulns-lfi.1'

          #
          # Keyword arguments for `Vulns::LFI.scan` and `Vulns::LFI.test`.
          #
          # @return [Hash{Symbol => Object}]
          #
          def scan_kwargs
            kwargs = super()

            kwargs[:os]    = options[:os]    if options[:os]
            kwargs[:depth] = options[:depth] if options[:depth]

            if options[:filter_bypass]
              kwargs[:filter_bypass] = options[:filter_bypass]
            end

            return kwargs
          end

          #
          # Scans a URL for LFI vulnerabilities.
          #
          # @param [String] url
          #   The URL to scan.
          #
          # @yield [vuln]
          #   The given block will be passed each discovered LFI vulnerability.
          #
          # @yieldparam [Vulns::LFI] vuln
          #   A LFI vulnerability discovered on the URL.
          #
          def scan_url(url,&block)
            Vulns::LFI.scan(url,**scan_kwargs,&block)
          end

          #
          # Tests a URL for LFI vulnerabilities.
          #
          # @param [String] url
          #   The URL to test.
          #
          # @return [Vulns::LFI, nil]
          #   The first LFI vulnerability discovered on the URL.
          #
          def test_url(url,&block)
            Vulns::LFI.test(url,**scan_kwargs)
          end

        end
      end
    end
  end
end
