
require 'cbor'
require 'date'
require 'json'

SenMLParseException = Class.new(Exception)

##
# Representation of a sensor measurement
class SensorReading
  attr_accessor :name, :time, :value, :unit
end

##
# see http://tools.ietf.org/html/draft-jennings-senml-10
# not implemented yet: version, sum and update time
class SenMLParser

  ##
  # parses simple hash
  # returns array of SensorReading objects
  def self.parse(obj_data)
    readings = []

    base_name , base_unit, base_time, elements =
      parse_base_elements(obj_data)

    elements.each do |item|
      readings << generate_sensor_reading(item, base_name,
                                          base_unit, base_time)
    end

    readings
  end

  ##
  # parses application/senml+json
  # returns array of SensorReading objects
  def self.parse_json(json_string)
    json_object = parse_json_string(json_string)
    parse(json_object)
  end

  ##
  # parses application/senml+cbor
  # returns array of SensorReading objects
  def self.parse_cbor(bin_data)
    object_data = CBOR.decode(bin_data)
    parse(object_data)
  end

  private

  def self.parse_json_string(json_string)
    begin
      json_object = JSON.parse(json_string)
    rescue
      raise SenMLParseException, 'Unable to parse JSON'
    end

    json_object
  end

  def self.parse_base_elements(obj)
    base_name = obj['bn'] || ''
    base_unit = obj['bu'] || ''
    # if there is no specification of time, it is assumed the reading
    # occured right now
    base_time = DateTime.now
    base_time = DateTime.strptime(obj['bt'].to_s, '%s')\
                if obj['bt']

    fail SenMLParseException,
         'No sensor readings found' unless obj['e']

    [base_name, base_unit, base_time, obj['e']]
  end

  def self.generate_sensor_reading(item, base_name, base_unit, base_time)
    new_reading = SensorReading.new
    new_reading.name = base_name + (item['n'] || '')
    new_reading.value = item['v'] || item['sv'] || item['bv']
    new_reading.unit = item['u'] || base_unit
    time_offset_seconds = item['t'] || 0
    new_reading.time = base_time + Rational(time_offset_seconds, 86_400)

    new_reading
  end

end
