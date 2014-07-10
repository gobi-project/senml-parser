require 'test/unit'
require 'senml_parser'

class SenMLParserTest < Test::Unit::TestCase

  def test_parse_single_datapoint_cbor
    senml_data = { 'e' => [{ 'n' => 'temperature',
                             'v' => 20, 'u' => '%degC' }] }
    # cbor_data =
    # a1 61 65 81 a3 61 6e 6b 74656d7065726174757265
    # 61 76 14 61 75 65 2564656743  (30 bytes)
    cbor_data = senml_data.to_cbor

    readings = SenMLParser.parse_cbor(cbor_data)
    assert_equal(1, readings.size)
    assert_equal('temperature', readings[0].name)
    assert_equal(20, readings[0].value)
    assert_equal('%degC', readings[0].unit)
  end

  # rubocop:disable MethodLength
  def test_parse_multiple_datapoints_cbor
    senml_data = { 'e' => [
                       { 'n' => 'voltage', 't' => 0, 'u' => 'V',
                         'v' => 120.1 },
                       { 'n' => 'current', 't' => 0, 'u' => 'A',
                         'v' => 1.2 }],
                   'bn' => 'urn:dev:mac:0024befffe804ff1/'
                   }
    # cbor_data =
    # a2616582a4616e67766f6c74616765617400617561566176fb405e066666666666
    # a4616e6763757272656e74617400617561416176fb3ff333333333333362626e78
    # 1d75726e3a6465763a6d61633a303032346265666666653830346666312f
    cbor_data = senml_data.to_cbor
    readings = SenMLParser.parse_cbor(cbor_data)

    assert_equal(2, readings.size)

    assert_equal('urn:dev:mac:0024befffe804ff1/voltage', readings[0].name)
    assert_equal(120.1, readings[0].value)
    assert_equal('V', readings[0].unit)
  end
  # rubocop:enable MethodLength

  def test_parse_single_datapoint_json
    senml_string = '{"e":[{ "n": "temperature", "v": 20, "u": "%degC" }]}'
    readings = SenMLParser.parse_json(senml_string)
    assert_equal(1, readings.size)
    assert_equal('temperature', readings[0].name)
    assert_equal(20, readings[0].value)
    assert_equal('%degC', readings[0].unit)
  end

  def test_parse_multiple_datapoints_json_1
    senml_string = '{"e":['\
                    '   { "n": "voltage", "t": 0, "u": "V", "v": 120.1 },'\
                    '   { "n": "current", "t": 0, "u": "A", "v": 1.2 }],'\
                    '   "bn": "urn:dev:mac:0024befffe804ff1/"'\
                    '}'
    readings = SenMLParser.parse_json(senml_string)
    assert_equal(2, readings.size)

    assert_equal('urn:dev:mac:0024befffe804ff1/current', readings[1].name)
    assert_equal(1.2, readings[1].value)
    assert_equal('A', readings[1].unit)
  end

  # exceeding 10 loc to check enough data elements in one test
  # should be readable though ;)
  # rubocop:disable MethodLength
  def test_parse_multiple_datapoints_json_2
    # Basetime = 31.10.2013 00:00:00
    senml_string = '{"e":[
                          { "v": 20.0, "t": 0 },
                          { "sv": "E 24\' 30.621", "u": "lon", "t": 0 },
                          { "sv": "N 60\' 7.965", "u": "lat", "t": 0 },
                          { "v": 20.3, "t": 60 },
                          { "sv": "E 24\' 30.622", "u": "lon", "t": 60 },
                          { "sv": "N 60\' 7.965", "u": "lat", "t": 60 },
                          { "v": 20.7, "t": 120 },
                          { "sv": "E 24\' 30.623", "u": "lon", "t": 120 },
                          { "sv": "N 60\' 7.966", "u": "lat", "t": 120 },
                          { "v": 98.0, "u": "%EL", "t": 150 },
                          { "v": 21.2, "t": 180 },
                          { "sv": "E 24\' 30.628", "u": "lon", "t": 180 },
                          { "sv": "N 60\' 7.967", "u": "lat", "t": 180 }],
                      "bn": "http://[2001:db8::1]",
                      "bt": 1383177600,
                      "bu": "%RH"
                     }'
    readings = SenMLParser.parse_json(senml_string)
    assert_equal(13, readings.size)

    assert_equal('http://[2001:db8::1]', readings[0].name)
    assert_equal(20.0, readings[0].value)
    assert_equal('%RH', readings[0].unit)
    assert_equal(31, readings[0].time.mday)
    assert_equal(10, readings[0].time.month)
    assert_equal(2013, readings[0].time.year)
    assert_equal(0, readings[0].time.min)

    assert_equal('http://[2001:db8::1]', readings[9].name)
    assert_equal(98.0, readings[9].value)
    assert_equal('%EL', readings[9].unit)
    assert_equal(31, readings[0].time.mday)
    assert_equal(2, readings[9].time.min)
    assert_equal(30, readings[9].time.sec)
  end
  # rubocop:enable MethodLength

  def test_parse_malformed_json_data
    senml_string = '{"bn": "node_without_data"}'
    assert_raise SenMLParseException do
      SenMLParser.parse_json(senml_string)
    end
  end

end
