# This file is part of rmss.

# rmss is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# rmss is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with rmss.  If not, see <http://www.gnu.org/licenses/>.

# Class representing our hardware with all the data recieved from it.

$CLASSPATH << "lib/usb"
require 'java'

class Device
  java_import 'LowLevelUSB'

  DEBUG = 0
  def initialize
    @temperature = []
    @humidity = []
    @acceleration = []
    @status = {}
    @connected = false
  end

  def connect
    begin
      @dev = LowLevelUSB.new(DEBUG)
    rescue Exception => why
      raise EOFError, why.to_s
    end
    @connected = true
  end

  def fetch_data
    begin
      if @dev
        return @dev.getInfo
      else
        return nil
      end
    rescue EOFError
      disconnect
      raise EOFError, "Device disconnected."
    rescue Exception => why
      Kernel::sleep(1)
      puts "Fetch failure: #{why.to_s}"
      retry
    end
  end

  def parse_data
    begin
      data = fetch_data
    rescue StandardError => why
      raise StandardError, why.to_s
    end
    @status['haveTS'] = data['haveTS']
    @status['haveAC'] = data['haveAC']
    @status['numberOfTS'] = data['numberOfTS']
    data['TSValues'].each do |value|
      @temperature << value.to_f / 10
    end
    data['HValues'].each do |value|
      @humidity << value
    end
    data['ACValues'].each do |value|
      @acceleration << Array.new(value)
    end
    # @acceleration = Array.new(data['ACValues'])
  end

  def status
    return @status
  end

  def connected?
    return @connected
  end

  def temperature
    return @temperature
  end

  def humidity
    return @humidity
  end

  def acceleration
    return @acceleration
  end

  def disconnect
    if @connected
      @dev.close
      @connected = false
    end
  end
end
