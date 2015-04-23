# Usage: lsc cleanup-nlsc.ls > villages.json
require! <[csv minimist fs topojson]>
{file} = minimist process.argv.slice 2
villages = []
var header
<- csv!from.stream fs.createReadStream \./tmp/villages.csv
.on \record (row,index) ->
    if index is 0
        header := row
    else
        entry = {[header[i], row[i]] for i of row}
        if [_, county, town, village]? = entry.id.match /(^6\d)00?(\d\d\d\d)-(.*)/
            entry.id = "#{county}#{town}0-#{village}"
        else if [_, county, town, village]? = entry.id.match /(^[01]\d\d\d\d)(\d\d)0-(.*)/
            entry.id = "#{county}#{town}-#{village}"
        villages.push entry
.on \end
# from http://tgos.nat.gov.tw/tgos/Web/MAPData/Apply/TGOS_Apply_FreeDownload.aspx?ID=1076
set = JSON.parse fs.readFileSync file, \utf-8

by-vid = {}

transform = ->
    f = do-transform(it)
    return unless f
    {bas_id: f.properties.VILLAGE_ID} <<< f.properties{ivid, itid, icid}

do-transform = ({properties}:f) ->
    console.warn f if properties.name is /海/
    populate-vid = (properties) ->
        console.log \===populate
        if properties.VILLAGE is /[村里]$/
            [matched] = [v for v in villages when v<[county town name]> === properties<[COUNTY TOWN VILLAGE]>]
            if matched
                console.error \ASSIGN: matched<[county town name]>, matched.id
                properties.VILLAGE_ID = matched.vid
                properties.V_ID = matched.id
            else
                console.error \NULL: properties<[C_Name T_Name V_Name]>
                return f
        else
            #console.error \NULL: properties<[COUNTY TOWN VILLAGE]>
            return f
    populate-vid properties unless properties.VILLAGE_ID

    if v = by-vid[properties.VILLAGE_ID]
        console.error "====has #{v} already, you might want to use topojson-group"

    return f unless properties.VILLAGE_ID
    if properties.VILLAGE_ID is /-S/
      [matched] = [v for v in villages when v<[county town]> === properties<[C_Name T_Name]>]
      throw JSON.stringify(properties, null, 4) unless matched
      properties <<< matched{itid, icid}
      return f 
    [matched] = [v for v in villages when v.id is properties.VILLAGE_ID]
    throw JSON.stringify(properties, null, 4) unless matched
    unless matched<[county town name]> === properties<[C_Name T_Name V_Name]>

        [alt] = [v for v in villages when v<[county town name]> === properties<[C_Name T_Name V_Name]>]

        console.error \FIX: matched.id, properties<[C_Name T_Name V_Name]>.join(''), \=>, matched<[county town name]>.join(''), if alt => "==> WARN" else ""
        properties.VILLAGE = matched.name
    by-vid[properties.VILLAGE_ID] = f
    properties <<< matched{ivid, itid, icid}
    f.id = matched.ivid
    f


topology = topojson.topology {villages: set}, {-verbose, quantization: 1e6, 'property-transform': transform}

seen = {[id, 1] for {id} in topology.objects.villages.geometries when id}
for {ivid}:v in villages when !seen[ivid]
    console.error "NOT FOUND", v<[county town name]>
    
console.log JSON.stringify topology
