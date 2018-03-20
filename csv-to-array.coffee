fs = require 'fs'

readCsv = (filename) ->
    csv = fs.readFileSync filename, 'utf8'
    lines = csv.trim().split('\n').map (line) ->
        line.trim().split(',')

module.exports = (filename) ->
    [header, lines...] = readCsv filename
    console.log 'header =', header
    console.log 'lines =', lines
    lines.map (line, obj_index) ->
        obj = {}
        line.forEach (v, v_index) ->
            if v == ''
                val = 0
            else if header[v_index] in ['origin_quantity', 'destination_quantity', 'usd_value']
                val = parseFloat v
            else
                val = v

            obj[header[v_index]] = val
        obj

