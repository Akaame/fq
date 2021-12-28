def bson_tovalue:
  def _tovalue:
   ( if .type == null or .type == "array" then .value.document | map(_tovalue)
     elif .type == "document" then .value.document | map({key: .name, value: _tovalue}) | from_entries
     elif .type == "boolean" then .value != 0
     else .value
     end
   );
  ( {type: "document", value: .}
  | _tovalue
  );
